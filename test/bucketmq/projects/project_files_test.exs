defmodule BucketMQ.Projects.ProjectFilesTest do
  use BucketMQ.DataCase, async: true
  alias BucketMQ.Projects.ProjectFiles

  @git_repo "git@github.com:sonerdy/bucketmq_examples.git"
  @slug "test_project"
  @project_folder "projects/test_project"
  @files [
    {"README.md", {:ok, "Contents of README.md"}},
    {"example.yml", {:ok, "Contents of example.yml"}},
    {"subfolder/another_example.yaml", {:ok, "Contents of subfolder/another_example.yaml"}}
  ]

  setup(context) do
    stub_project = %BucketMQ.Projects.Project{
      slug: @slug,
      git_repo: @git_repo,
      title: "Test Project"
    }

    system_stub = System
    |> double()
    |> allow(:get_env, fn("BUCKETMQ_PROJECTS_FOLDER") -> nil end)
    |> allow(:cmd, fn("git", ["clone", @git_repo, @slug], [cd: "projects"]) -> {"\n", 0} end)
    |> allow(:cmd, fn("git", ["pull"], [cd: @project_folder]) -> {"\n", 0} end)

    files = context[:files] || @files

    file_stub = File
    |> double()
    |> allow(:mkdir_p!, fn(@project_folder) -> :ok end)
    |> allow(:read, fn(arg_path) ->
      files
      |> Enum.find({arg_path, {:error, :enoent}}, fn({path, _contents}) ->
        "#{@project_folder}/#{path}" == arg_path
      end)
      |> elem(1)
    end)

    path_stub = Path
    |> double()
    |> allow(:wildcard, fn(pattern) ->
      if pattern == "#{@project_folder}/**/*.{yml,yaml,md,markdown}" do
        Enum.map(files, fn({file_path, _}) -> "#{@project_folder}/#{file_path}" end)
      else
        []
      end
    end)

    projects_stub = BucketMQ.Projects
    |> double()
    |> allow(:list_projects, fn -> [stub_project] end)

    pubsub_stub = BucketMQ.PubSub
    |> double()
    |> allow(:subscribe, fn(_topic, {_mod, _fun}) -> :ok end)

    deps = %{
      system: system_stub,
      file: file_stub,
      path: path_stub,
      pubsub: pubsub_stub,
      projects: projects_stub
    }

    {:ok, pid} = GenServer.start_link(ProjectFiles, deps)

    context
    |> Map.put(:pid, pid)
    |> Map.put(:project, stub_project)
  end

  test "init subscribes to project events" do
    assert_receive {:subscribe, :project_created, {ProjectFiles, :add_project}}
    assert_receive {:subscribe, :project_updated, {ProjectFiles, :update_project}}
    assert_receive {:subscribe, :project_deleted, {ProjectFiles, :remove_project}}
  end

  describe "&get_projects/1" do
    test "returns projects and their files", %{pid: pid, project: stub_project} do
      projects = ProjectFiles.get_projects(pid)

      project = projects |> Map.keys |> List.first
      files = Map.get(projects, project)
      assert files == %{
                "README.md" => "Contents of README.md",
                "example.yml" => "Contents of example.yml",
                "subfolder" => %{
                  "another_example.yaml" => "Contents of subfolder/another_example.yaml"
                }
              }
      assert project == stub_project
    end
  end

  describe "&add_project/1" do
    test "adds the project and its files" do

    end
  end
end
