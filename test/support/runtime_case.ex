defmodule Commanded.Scheduler.RuntimeCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Commanded.EventStore.Adapters.InMemory
  alias Commanded.Helpers.ProcessHelper
  alias Commanded.Scheduler.Repo
  alias Commanded.Serialization.JsonSerializer

  setup_all do
    database_config = Application.get_env(:commanded_scheduler, Repo)

    Application.ensure_all_started(:postgrex)

    {:ok, conn} = Postgrex.start_link(database_config)

    [conn: conn]
  end

  setup %{conn: conn} do
    reset_database!(conn)

    {:ok, _} = Application.ensure_all_started(:commanded)
    {:ok, _} = Application.ensure_all_started(:commanded_scheduler)

    on_exit(fn ->
      Application.stop(:commanded_scheduler)
      Application.stop(:commanded)
    end)

    :ok
  end

  defp reset_database!(conn) do
    Postgrex.query!(
      conn,
      """
        TRUNCATE TABLE
          projection_versions,
          schedules
        RESTART IDENTITY;
      """,
      []
    )
  end
end
