defmodule BucketMQ.Projects.ProjectFilesTest do
  use BucketMQ.DataCase, async: true
  alias BucketMQ.Projects.ProjectFiles

  @git_repo "git@github.com:sonerdy/bucketmq_examples.git"
  @slug "test_project"
  @project_dir "projects/test_project"

  test "init subscribes to project events" do
    {:ok, pid} = GenServer.start_link(ProjectFiles, deps())
    assert_receive {:subscribe, :project_created, {ProjectFiles, :add_project}}
    assert_receive {:subscribe, :project_updated, {ProjectFiles, :update_project}}
    assert_receive {:subscribe, :project_deleted, {ProjectFiles, :remove_project}}
  end

  test "&set_projects/1 sets the project state" do
    deps = deps()
    {:ok, pid} = GenServer.start_link(ProjectFiles, deps)
    projects = [stub_project()]
    ProjectFiles.set_projects(projects, pid)
    state = ProjectFiles.get_state(pid)
    assert state.projects == projects
  end

  defp stub_project do
    %BucketMQ.Projects.Project{
      slug: @slug,
      git_repo: @git_repo,
      title: "Test Project"
    }
  end

  defp deps do
    system_stub = System
    |> double()
    |> allow(:get_env, fn("BUCKETMQ_PROJECTS_FOLDER") -> nil end)
    |> allow(:cmd, fn("git", ["clone", @git_repo, @slug], [cd: "projects"]) -> {"\n", 0} end)
    |> allow(:cmd, fn("git", ["pull"], [cd: @project_dir]) -> {"\n", 0} end)

    file_stub = File
    |> double()
    |> allow(:mkdir_p!, fn("projects/test_project") -> :ok end)

    path_stub = Path
    |> double()
    |> allow(:wildcard, fn("projects/test_project/**/*.{yml,yaml,md,markdown}") ->
      [
        "projects/test_project/README.md",
        "projects/test_project/example.yml"
      ]
    end)

    pubsub_stub = BucketMQ.PubSub
    |> double()
    |> allow(:subscribe, fn(_topic, {_mod, _fun}) -> :ok end)

    %{
      system: system_stub,
      file: file_stub,
      path: path_stub,
      pubsub: pubsub_stub
    }
  end
end
