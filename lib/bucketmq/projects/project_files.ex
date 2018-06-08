defmodule BucketMQ.Projects.ProjectFiles do
  use GenServer

  @projects_folder_key "BUCKETMQ_PROJECTS_FOLDER"
  @default_projects_folder "projects"
  @acceptable_filetypes ["yml", "yaml", "md", "markdown"]
  @deps %{
    system: System,
    file: File,
    pubsub: BucketMQ.PubSub,
    path: Path,
    projects: BucketMQ.Projects
  }

  defmodule State do
    defstruct deps: @deps, projects: %{}
  end

  def init(deps \\ @deps) do
    deps.pubsub.subscribe(:project_created, {__MODULE__, :add_project})
    deps.pubsub.subscribe(:project_updated, {__MODULE__, :update_project})
    deps.pubsub.subscribe(:project_deleted, {__MODULE__, :remove_project})
    projects = deps.projects.list_projects()
    |> Enum.reduce(%{}, fn(project, acc) ->
      Map.put(acc, project, crawl(project, deps))
    end)
    state = %State{deps: deps, projects: projects}
    {:ok, state}
  end

  def get_projects(pid \\ __MODULE__) do
    GenServer.call(pid, :get_projects)
  end

  @impl true
  def handle_call(:get_projects, _from, state) do
    {:reply, state.projects, state}
  end

  def fetch_project(project, deps \\ @deps) do
    projects_dir = deps.system.get_env(@projects_folder_key) || @default_projects_folder
    ensure_projects_folder!(projects_folder(deps), deps)
    ensure_project_cloned(projects_folder(deps), project, deps)
    pull_latest(projects_folder(deps), project, deps)
  end

  def crawl(project, deps \\ @deps) do
    project
    |> list_files(deps)
    |> read_files([], deps)
    |> map_files(%{}, deps)
  end

  defp list_files(project, deps) do
    extensions = @acceptable_filetypes |> Enum.join(",")
    project_folder = "#{project_folder(project, deps)}/"
    "#{project_folder}**/*.{#{extensions}}"
    |> deps.path.wildcard()
    |> Enum.map(fn(file) ->
      subfolder = String.replace_leading(file, project_folder, "")
      {file, subfolder}
    end)
  end

  defp map_files([], state, deps), do: state
  defp map_files([{subfolder, contents} | files], state, deps) do
    path_parts = subfolder |> String.split("/")
    state = put_in(state, Enum.map(path_parts, &Access.key(&1, %{})), contents)
    map_files(files, state, deps)
  end

  defp read_files([], result, _deps), do: result
  defp read_files([{file, subfolder} | files], result, deps) do
    {:ok, contents} = deps.file.read(file)
    read_files(files, result ++ [{subfolder, contents}], deps)
  end

  defp projects_folder(deps) do
    deps.system.get_env(@projects_folder_key) || @default_projects_folder
  end

  defp project_folder(project, deps) do
    "#{projects_folder(deps)}/#{project.slug}"
  end

  defp ensure_projects_folder!(dir, %{file: file}) do
    :ok = file.mkdir_p!(dir)
  end

  defp ensure_project_cloned(projects_dir, project, %{system: system}) do
    system.cmd(
      "git",
      ["clone", project.git_repo, project.slug],
      [cd: projects_dir]
    )
  end

  defp pull_latest(projects_dir, project, %{system: system}) do
    project_dir = "#{projects_dir}/#{project.slug}"
    {_, 0} = system.cmd(
      "git",
      ["pull"],
      [cd: project_dir]
    )
  end
end
