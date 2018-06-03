defmodule BucketMQ.PubSubTest do
  use BucketMQ.LibCase, async: true
  alias BucketMQ.PubSub
  alias BucketMQ.PubSub.InvalidTopicError

  test "invalid topics raise error" do
    assert_raise InvalidTopicError, fn ->
      PubSub.subscribe(:totally_not_a_topic, {IO, :inspect})
    end
  end

  test "valid topics return :ok" do
    assert :ok = PubSub.subscribe(:project_created, {IO, :inspect})
  end
end
