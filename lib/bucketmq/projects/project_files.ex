defmodule BucketMQ.Projects.ProjectFiles do
  @projects_folder_key "BUCKETMQ_PROJECTS_FOLDER"
  @default_projects_folder "projects"
  @acceptable_filetypes ["yml", "yaml", "md", "markdown"]
  @deps %{system: System, file: File}

  def fetch_project(project, deps \\ @deps) do
    projects_dir = deps.system.get_env(@projects_folder_key) || @default_projects_folder
    ensure_projects_folder!(projects_folder(deps), deps)
    ensure_project_cloned(projects_folder(deps), project, deps)
    pull_latest(projects_folder(deps), project, deps)
  end

  @doc """
  Returns a map of the project config.
  %{
    "foldername" => %{
      "README.md" => "#README CONTENTS",
      "filename.yml" => "yaml"
    }
  }
  """
  def crawl(project, deps \\ @deps) do
    extensions = @acceptable_filetypes |> Enum.join(",")

    files = "#{project_folder(project, deps)}/**/*.{#{extensions}}"
    |> Path.wildcard()
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
    file.mkdir_p!(dir)
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
      [cd: projects_dir]
    )
  end
end
