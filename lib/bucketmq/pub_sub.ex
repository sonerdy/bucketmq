defmodule BucketMQ.PubSub do
  @moduledoc """
  This is used to notify changes of projects to all services.
  This might be replaced by Kafka or Postgres NOTIFY later.
  """

  @topics [
    :project_created,
    :project_updated,
    :project_deleted,
  ]

  defmodule InvalidTopicError do
    defexception message: "Invalid topic for subscription"
  end

  def publish(topic, message) do
    Registry.dispatch(:bucketmq_pubsub, topic, fn(entries) ->
      for {_pid, {mod, fun}} <- entries, do: apply(mod, fun, [message])
    end)
  end

  def subscribe(topic, {_mod, _fun} = tuple) do
    case Enum.member?(@topics, topic) do
      true -> {:ok, _} = Registry.register(:bucketmq_pubsub, topic, tuple)
      false -> raise InvalidTopicError
    end
    :ok
  end
end
