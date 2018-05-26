ExUnit.start()
Application.ensure_all_started(:double)
{:ok, _} = Application.ensure_all_started(:ex_machina)

Ecto.Adapters.SQL.Sandbox.mode(BucketMQ.Repo, :manual)

