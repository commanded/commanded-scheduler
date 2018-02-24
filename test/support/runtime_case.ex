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
    {:ok, event_store} = InMemory.start_link(serializer: JsonSerializer)

    reset_database(conn)

    Application.ensure_all_started(:commanded)
    Application.ensure_all_started(:commanded_scheduler)

    on_exit(fn ->
      Application.stop(:commanded_scheduler)
      Application.stop(:commanded)

      ProcessHelper.shutdown(event_store)
    end)

    :ok
  end

  defp reset_database(conn) do
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
