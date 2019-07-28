defmodule Commanded.Scheduler.RuntimeCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Commanded.Scheduler.Repo

  setup_all do
    database_config = Application.get_env(:commanded_scheduler, Repo)

    Application.ensure_all_started(:postgrex)

    {:ok, conn} = Postgrex.start_link(database_config)

    {:ok, es} =
      EventStore.configuration()
      |> EventStore.Config.parse()
      |> EventStore.Config.default_postgrex_opts()
      |> Postgrex.start_link()

    [conn: conn, es: es]
  end

  setup %{conn: conn, es: es} do
    reset_database!(conn)
    reset_eventstore!(es)

    {:ok, _} = Application.ensure_all_started(:eventstore)
    {:ok, _} = Application.ensure_all_started(:commanded)
    {:ok, _} = Application.ensure_all_started(:commanded_scheduler)

    on_exit(fn ->
      Application.stop(:commanded_scheduler)
      Application.stop(:commanded)
      Application.stop(:eventstore)
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

  defp reset_eventstore!(conn) do
    EventStore.Storage.Initializer.reset!(conn)
  end
end
