defmodule Commanded.Scheduling.SchedulingTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions
  import Commanded.Scheduler.Factory

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.{Dispatcher, Jobs, OneOffJob, Repo, TriggerSchedule}
  alias Commanded.Scheduler.Projection.Schedule
  alias ExampleDomain.TicketBooking.Events.ReservationExpired

  setup do
    {:ok, handler} = ExampleDomain.TimeoutReservationHandler.start_link()

    on_exit(fn ->
      Commanded.Helpers.ProcessHelper.shutdown(handler)
    end)
  end

  describe "schedule once" do
    setup [:schedule_once]

    test "should schedule job", context do
      assert_job_scheduled(context)
    end
  end

  describe "schedule elapsed" do
    setup [:reserve_ticket, :wait_until_job_scheduled]

    test "should dispatch scheduled command", context do
      assert :ok = Jobs.run_jobs(context.expires_at)

      assert_receive_event(ReservationExpired, fn event ->
        assert event.ticket_uuid == context.ticket_uuid
      end)
    end
  end

  describe "restart scheduling" do
    setup [:reserve_ticket, :wait_until_job_persisted]

    test "should reschedule existing schedules on start", context do
      restart_scheduler_app()
      assert_job_scheduled(context)
    end
  end

  defp wait_until_job_scheduled(_context) do
    Wait.until(fn -> assert Jobs.scheduled_jobs() != [] end)
    :ok
  end

  defp wait_until_job_persisted(_context) do
    Wait.until(fn -> assert Repo.all(Schedule) != [] end)
    :ok
  end

  defp restart_scheduler_app do
    :ok = Application.stop(:commanded_scheduler)
    {:ok, _} = Application.ensure_all_started(:commanded_scheduler)
  end

  defp assert_job_scheduled(context) do
    %{
      due_at: due_at,
      schedule_uuid: schedule_uuid,
      schedule_name: name
    } = context

    trigger_schedule = %TriggerSchedule{
      schedule_uuid: schedule_uuid,
      name: name
    }

    Wait.until(fn ->
      assert Jobs.scheduled_jobs() == [
               %OneOffJob{
                 name: {schedule_uuid, name},
                 module: Dispatcher,
                 args: trigger_schedule,
                 run_at: NaiveDateTime.truncate(due_at, :second)
               }
             ]
    end)
  end
end
