defmodule BucketMQ.PubSub do
  def publish(topic, message) do
    Registry.dispatch(:bucketmq_pubsub, topic, fn(entries) ->
      for {pid, {mod, fun}} <- entries, do: apply(mod, fun, [message])
    end)
  end

  def subscribe(topic, {mod, fun} = tuple) do
    {:ok, _} = Registry.register(:bucketmq_pubsub, topic, tuple)
  end
end
