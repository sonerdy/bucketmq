defmodule BucketMQ.Projects.ProjectFiles do
  use GenServer

  @projects_folder_key "BUCKETMQ_PROJECTS_FOLDER"
  @default_projects_folder "projects"
  @acceptable_filetypes ["yml", "yaml", "md", "markdown"]
  @deps %{
    system: System,
    file: File,
    pubsub: BucketMQ.PubSub,
    path: Path
  }

  defmodule State do
    defstruct deps: @deps, projects: [], project_files: %{}
  end

  def init(deps \\ @deps) do
    deps.pubsub.subscribe(:project_created, {__MODULE__, :add_project})
    deps.pubsub.subscribe(:project_updated, {__MODULE__, :update_project})
    deps.pubsub.subscribe(:project_deleted, {__MODULE__, :remove_project})
    {:ok, %State{deps: deps}}
  end

  @doc """
  Used to initialize the list of projects.
  """
  def set_projects(projects, pid \\ __MODULE__) do
    GenServer.cast(pid, {:set_projects, projects})
  end

  def get_state(pid \\ __MODULE__) do
    GenServer.call(pid, :get_state)
  end

  @impl true
  def handle_cast({:set_projects, projects}, state) do
    {:noreply, %{state | projects: projects}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end


  def fetch_project(project, deps \\ @deps) do
    projects_dir = deps.system.get_env(@projects_folder_key) || @default_projects_folder
    ensure_projects_folder!(projects_folder(deps), deps)
    ensure_project_cloned(projects_folder(deps), project, deps)
    pull_latest(projects_folder(deps), project, deps)
  end

  def crawl(project, deps \\ @deps) do
    extensions = @acceptable_filetypes |> Enum.join(",")

    files = "#{project_folder(project, deps)}/**/*.{#{extensions}}"
    |> deps.path.wildcard()
    |> map_files(%{}, deps)
  end

  defp map_files([], state, _deps), do: state
  defp map_files([file | files], state, deps) do
    file_contents = File.read!(file)
    path_parts = file |> String.split("/")
    put_in(state, Enum.map(path_parts, &Access.key(&1, %{})), file_contents)
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
