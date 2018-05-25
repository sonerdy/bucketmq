defmodule BucketMQ.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :title, :string
      add :slug, :string
      add :git_repo, :string

      timestamps()
    end

    create unique_index(:projects, [:title])
    create unique_index(:projects, [:slug])
  end
end
