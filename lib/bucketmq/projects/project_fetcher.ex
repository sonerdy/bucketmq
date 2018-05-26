defmodule BucketMQ.ProjectFetcher do
  use GenServer
  alias BucketMQ.Projects

  defmodule State do
    defstruct projects_context: Projects, projects: []
  end


  @impl true
  def init(projects_context) do
    state = %State{projects_context: projects_context}
    GenServer.cast(self(), :update_projects)
    {:ok, state}
  end

  # API
  def projects(pid) do
    GenServer.call(pid, :projects)
  end

  @impl true
  def handle_call(:projects, _from, state) do
    {:reply, state.projects, state}
  end

  @impl true
  def handle_cast(:update_projects, state) do
    {
      :noreply,
      %{state | projects: state.projects_context.list_projects()}
    }
  end
end
