defmodule Commanded.Scheduling.DispatcherTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions
  import Commanded.Scheduler.Factory

  alias Commanded.Scheduler.{Dispatcher, ScheduleTriggered, TriggerSchedule}

  describe "dispatcher" do
    setup [:schedule_once, :trigger_schedule]

    test "should dispatch command", context do
      assert_receive_event(ScheduleTriggered, fn event ->
        %{
          schedule_uuid: schedule_uuid,
          command: command,
          command_type: command_type
        } = event

        assert schedule_uuid == context.schedule_uuid
        assert command == context.command
        assert command_type == "Elixir.ExampleDomain.TicketBooking.Commands.TimeoutReservation"
      end)
    end

    test "should fail to dispatch unscheduled job", %{schedule_name: name} do
      trigger_schedule = %TriggerSchedule{schedule_uuid: "doesnotexist", name: name}

      assert {:error, :no_schedule} = Dispatcher.execute("doesnotexist", trigger_schedule)
    end

    test "should fail to dispatch unnamed job", %{schedule_uuid: schedule_uuid} do
      trigger_schedule = %TriggerSchedule{schedule_uuid: schedule_uuid, name: nil}

      assert {:error, :no_schedule} = Dispatcher.execute(schedule_uuid, trigger_schedule)
    end

    test "should execute dispatch as scheduled job", context do
      assert_receive_event(ScheduleTriggered, fn event ->
        assert event.schedule_uuid == context.schedule_uuid
      end)
    end
  end
end
