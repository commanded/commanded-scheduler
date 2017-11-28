defmodule Commanded.Scheduler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Commanded.Scheduler.Repo,
      Commanded.Scheduler.Jobs,
      Commanded.Scheduler.JobScheduler,
    ]

    opts = [strategy: :one_for_one, name: Commanded.Scheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
