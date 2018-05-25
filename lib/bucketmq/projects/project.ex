defmodule BucketMQ.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset


  schema "projects" do
    field :git_repo, :string
    field :slug, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :slug, :git_repo])
    |> validate_required([:title, :slug, :git_repo])
    |> unique_constraint(:title)
    |> unique_constraint(:slug)
  end
end
