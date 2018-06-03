defmodule BucketMQ.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias BucketMQ.Repo

  alias BucketMQ.Projects.Project

  @pubsub BucketMQ.PubSub

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}, pubsub \\ @pubsub) do
    result = %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
    case result do
      {:ok, project} -> pubsub.publish(:project_created, project)
      _ -> :noop
    end
    result
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs, pubsub \\ @pubsub) do
    result = project
    |> Project.changeset(attrs)
    |> Repo.update()
    case result do
      {:ok, project} -> pubsub.publish(:project_updated, project)
      _ -> :noop
    end
    result
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project, pubsub \\ @pubsub) do
    result = Repo.delete(project)
    case result do
      {:ok, project} -> pubsub.publish(:project_deleted, project)
      _ -> :noop
    end
    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end
end
