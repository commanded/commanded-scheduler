defmodule Commanded.SchedulerTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions

  alias Commanded.Scheduler.Commands.{ScheduleOnce,ScheduleRecurring}
  alias Commanded.Scheduler.Events.{ScheduledOnce,ScheduledRecurring}
  alias Commanded.Scheduler.Router

  defmodule ExampleCommand, do: defstruct [:aggregate_uuid, :data]

  describe "schedule once" do
    test "should create scheduled once domain event" do
      schedule_uuid = UUID.uuid4()
      aggregate_uuid = UUID.uuid4()
      due_at = NaiveDateTime.utc_now()
      command = %ExampleCommand{
        aggregate_uuid: aggregate_uuid,
        data: "example",
      }

      assert :ok = Router.dispatch(%ScheduleOnce{
        schedule_uuid: schedule_uuid,
        command: command,
        due_at: due_at,
      })

      assert_receive_event ScheduledOnce, fn scheduled ->
        assert scheduled.schedule_uuid == schedule_uuid
        assert scheduled.command == command
        assert scheduled.command_type == "Elixir.Commanded.SchedulerTest.ExampleCommand"
        assert scheduled.due_at == due_at
      end
    end
  end

  describe "schedule recurring" do
    test "should create scheduled recurring domain event" do
      schedule_uuid = UUID.uuid4()
      aggregate_uuid = UUID.uuid4()
      command = %ExampleCommand{
        aggregate_uuid: aggregate_uuid,
        data: "example",
      }

      assert :ok = Router.dispatch(%ScheduleRecurring{
        schedule_uuid: schedule_uuid,
        command: command,
        schedule: "@daily"
      })

      assert_receive_event ScheduledRecurring, fn scheduled ->
        assert scheduled.schedule_uuid == schedule_uuid
        assert scheduled.command == command
        assert scheduled.command_type == "Elixir.Commanded.SchedulerTest.ExampleCommand"
        assert scheduled.schedule == "@daily"
      end
    end
  end
end
