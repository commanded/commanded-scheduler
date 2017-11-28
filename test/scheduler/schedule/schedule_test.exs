defmodule Commanded.ScheduleTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions

  alias Commanded.Scheduler.{
    ScheduleOnce,
    ScheduledOnce,
    ScheduleRecurring,
    ScheduledRecurring,
  }
  alias Commanded.Scheduler.Router

  defmodule ExampleCommand, do: defstruct [:aggregate_uuid, :data]

  describe "schedule once" do
    setup [:schedule_once]

    test "should create scheduled once domain event", context do
      assert_receive_event ScheduledOnce, fn scheduled ->
        assert scheduled.schedule_uuid == context.schedule_uuid
        assert scheduled.command == context.command
        assert scheduled.command_type == "Elixir.Commanded.ScheduleTest.ExampleCommand"
        assert scheduled.due_at == context.due_at
      end
    end
  end

  describe "schedule recurring" do
    setup [:schedule_recurring]

    test "should create scheduled recurring domain event", context do
      assert_receive_event ScheduledRecurring, fn scheduled ->
        assert scheduled.schedule_uuid == context.schedule_uuid
        assert scheduled.command == context.command
        assert scheduled.command_type == "Elixir.Commanded.ScheduleTest.ExampleCommand"
        assert scheduled.schedule == "@daily"
      end
    end
  end

  defp schedule_once(_context) do
    schedule_uuid = UUID.uuid4()
    aggregate_uuid = UUID.uuid4()
    due_at = NaiveDateTime.utc_now()
    command = %ExampleCommand{
      aggregate_uuid: aggregate_uuid,
      data: "example",
    }
    schedule_once = %ScheduleOnce{
      schedule_uuid: schedule_uuid,
      command: command,
      due_at: due_at,
    }

    :ok = Router.dispatch(schedule_once)

    [
      schedule_uuid: schedule_uuid,
      aggregate_uuid: aggregate_uuid,
      due_at: due_at,
      command: command,
    ]
  end

  defp schedule_recurring(_context) do
    schedule_uuid = UUID.uuid4()
    aggregate_uuid = UUID.uuid4()
    command = %ExampleCommand{
      aggregate_uuid: aggregate_uuid,
      data: "example",
    }
    schedule_recurring = %ScheduleRecurring{
      schedule_uuid: schedule_uuid,
      command: command,
      schedule: "@daily"
    }

    :ok = Router.dispatch(schedule_recurring)

    [
      schedule_uuid: schedule_uuid,
      aggregate_uuid: aggregate_uuid,
      command: command,
    ]
  end
end
