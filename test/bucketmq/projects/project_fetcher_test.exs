defmodule BucketMQ.ProjectFetcherTest do
  alias BucketMQ.Projects
  alias BucketMQ.ProjectFetcher
  use ExUnit.Case, async: true
  import Double
  import BucketMQ.Factory

  describe "projects" do
    test "returns projects from context" do
      project = build(:project)
      context = Projects
      |> double()
      |> allow(:list_projects, fn -> [project] end)
      {:ok, pid} = GenServer.start_link(ProjectFetcher, context)
      result = ProjectFetcher.projects(pid)
      assert result == [project]
    end
  end
end
