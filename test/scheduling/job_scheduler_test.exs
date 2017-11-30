defmodule Commanded.JobSchedulerTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Scheduler.Factory

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.JobScheduler.Schedule
  alias Commanded.Scheduler.{Dispatcher,Jobs,OneOffJob,Repo}

  describe "schedule once" do
    setup [:schedule_once]

    test "should persist scheduled job", context do
      {:ok, schedule} = get_schedule(context.schedule_uuid)

      assert schedule.command == %{
        "aggregate_uuid" => context.aggregate_uuid,
        "data" => "example",
      }
      assert schedule.command_type == "Elixir.Commanded.Scheduler.ExampleCommand"
      assert schedule.due_at == context.due_at
    end

    test "should schedule job", context do
      Wait.until(fn ->
        assert Jobs.scheduled_jobs() == [
          %OneOffJob{
            name: context.schedule_uuid,
            module: Dispatcher,
            args: context.command,
            run_at: context.due_at,
          }
        ]
      end)
    end
  end

  defp get_schedule(schedule_uuid) do
    Wait.until(fn ->
      case Repo.get(Schedule, schedule_uuid) do
        nil -> flunk("Schedule #{inspect schedule_uuid} does not exist")
        schedule -> {:ok, schedule}
      end
    end)
  end
end
