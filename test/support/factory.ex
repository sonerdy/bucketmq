defmodule BucketMQ.Factory do
  use ExMachina.Ecto, repo: BucketMQ.Repo

  def project_factory do
    %BucketMQ.Projects.Project{
      title: "Test Project",
      slug: "test-project",
      git_repo: "git@github.com:sonerdy/bucketmq_examples.git"
    }
  end
end
