defmodule Commanded.Scheduler.JobScheduler do
  @moduledoc false

  use Commanded.Projections.Ecto,
    name: "Commanded.Scheduler",
    repo: Commanded.Scheduler.Repo
end
