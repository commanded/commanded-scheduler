defmodule Commanded.ScheduleTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions
  import Commanded.Scheduler.Factory

  alias Commanded.Scheduler.{
    Router,
    ScheduleOnce,
    ScheduledOnce,
    ScheduleRecurring,
    ScheduledRecurring,
  }

  describe "schedule once" do
    setup [:schedule_once]

    test "should create scheduled once domain event", context do
      assert_receive_event ScheduledOnce, fn scheduled ->
        assert scheduled.schedule_uuid == context.schedule_uuid
        assert scheduled.command == context.command
        assert scheduled.command_type == "Elixir.ExampleDomain.TicketBooking.Commands.TimeoutReservation"
        assert scheduled.due_at == context.due_at
      end
    end

    test "should error attempting to schedule duplicate", context do
      schedule_once = %ScheduleOnce{
        schedule_uuid: context.schedule_uuid,
        command: context.command,
        due_at: context.due_at,
      }

      assert {:error, :already_scheduled} = Router.dispatch(schedule_once)
    end
  end

  describe "schedule recurring" do
    setup [:schedule_recurring]

    test "should create scheduled recurring domain event", context do
      assert_receive_event ScheduledRecurring, fn scheduled ->
        assert scheduled.schedule_uuid == context.schedule_uuid
        assert scheduled.command == context.command
        assert scheduled.command_type == "Elixir.Commanded.Scheduler.ExampleCommand"
        assert scheduled.schedule == "@daily"
      end
    end

    test "should error attempting to schedule duplicate", context do
      schedule_recurring = %ScheduleRecurring{
        schedule_uuid: context.schedule_uuid,
        command: context.command,
        schedule: context.schedule,
      }

      assert {:error, :already_scheduled} = Router.dispatch(schedule_recurring)
    end
  end
end
