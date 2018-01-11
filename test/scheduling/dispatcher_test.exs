defmodule Commanded.Scheduling.DispatcherTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions
  import Commanded.Scheduler.Factory

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.{Dispatcher,Jobs,ScheduleElapsed,TriggerSchedule}

  describe "dispatcher" do
    setup [:schedule_once]

    test "should dispatch command", context do
      trigger_schedule = %TriggerSchedule{schedule_uuid: context.schedule_uuid}

      assert :ok = Dispatcher.execute(context.schedule_uuid, trigger_schedule)

      assert_receive_event ScheduleElapsed, fn event ->
        assert event.schedule_uuid == context.schedule_uuid
        assert event.command == context.command
        assert event.command_type == "Elixir.ExampleDomain.TicketBooking.Commands.TimeoutReservation"
      end
    end

    test "should execute dispatch as scheduled job", context do
      now = NaiveDateTime.utc_now()

      Wait.until(fn -> assert Jobs.scheduled_jobs() != [] end)

      assert :ok = Jobs.run_jobs(now)

      assert_receive_event ScheduleElapsed, fn event ->
        assert event.schedule_uuid == context.schedule_uuid
      end
    end
  end
end
