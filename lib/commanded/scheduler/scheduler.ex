defmodule Commanded.Scheduler do
  @moduledoc """
  One-off and recurring command scheduler for
  [Commanded](https://hex.pm/packages/commanded) CQRS/ES applications.
  """

  use Commanded.Projections.Ecto,
    name: "Commanded.Scheduler",
    repo: Commanded.Scheduler.Repo
end
