defmodule BucketMQ.LibCase do
  @moduledoc """
  This module defines the test case to be used by
  general lib modules.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Double
    end
  end
end
