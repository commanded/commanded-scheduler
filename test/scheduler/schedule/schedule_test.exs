defmodule Commanded.ScheduleTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions
  import Commanded.Scheduler.Factory

  alias Commanded.Scheduler.{
    ScheduledOnce,
    ScheduledRecurring,
  }

  describe "schedule once" do
    setup [:schedule_once]

    test "should create scheduled once domain event", context do
      assert_receive_event ScheduledOnce, fn scheduled ->
        assert scheduled.schedule_uuid == context.schedule_uuid
        assert scheduled.command == context.command
        assert scheduled.command_type == "Elixir.Commanded.Scheduler.ExampleCommand"
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
        assert scheduled.command_type == "Elixir.Commanded.Scheduler.ExampleCommand"
        assert scheduled.schedule == "@daily"
      end
    end
  end
end
