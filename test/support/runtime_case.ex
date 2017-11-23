defmodule Commanded.Scheduler.RuntimeCase do
  use ExUnit.CaseTemplate

  setup do
    {:ok, event_store} = Commanded.EventStore.Adapters.InMemory.start_link()

    Application.ensure_all_started(:commanded)
    Application.ensure_all_started(:commanded_scheduler)

    on_exit fn ->
      shutdown(event_store)
    end

    :ok
  end

  def shutdown(pid) when is_pid(pid) do
    Process.unlink(pid)
    Process.exit(pid, :shutdown)

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}, 5_000
  end
end
