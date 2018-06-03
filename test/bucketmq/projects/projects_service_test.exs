defmodule BucketMQ.Projects.ProjectsServiceTest do
  alias BucketMQ.Projects
  alias BucketMQ.Projects.ProjectsService
  use ExUnit.Case, async: true
  import Double
  import BucketMQ.Factory

  describe "projects" do
    test "returns projects from context" do
      project = build(:project)
      context = Projects
      |> double()
      |> allow(:list_projects, fn -> [project] end)
      {:ok, pid} = GenServer.start_link(ProjectsService, context)
      result = ProjectsService.projects(pid)
      assert result == [project]
    end
  end
end
