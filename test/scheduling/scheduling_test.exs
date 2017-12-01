defmodule Commanded.Scheduling.SchedulingTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions
  import Commanded.Scheduler.Factory

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.{Dispatcher,Jobs,OneOffJob,TriggerSchedule}
  alias ExampleDomain.TicketCompositeRouter
  alias ExampleDomain.TicketBooking.Commands.ReserveTicket
  alias ExampleDomain.TicketBooking.Events.ReservationExpired

  setup do
    Application.put_env(:commanded_scheduler, :router, TicketCompositeRouter)
    {:ok, handler} = ExampleDomain.TimeoutReservationHandler.start_link()

    on_exit fn ->
      Application.put_env(:commanded_scheduler, :router, nil)
      Commanded.Helpers.ProcessHelper.shutdown(handler)
    end
  end

  describe "schedule once" do
    setup [:schedule_once]

    test "should schedule job", context do
      trigger_schedule = %TriggerSchedule{schedule_uuid: context.schedule_uuid}

      Wait.until(fn ->
        assert Jobs.scheduled_jobs() == [
          %OneOffJob{
            name: context.schedule_uuid,
            module: Dispatcher,
            args: trigger_schedule,
            run_at: context.due_at,
          }
        ]
      end)
    end
  end

  describe "schedule elapsed" do
    setup [:reserve_ticket]

    test "should dispatch scheduled command", context do
      Wait.until(fn ->
        assert Jobs.scheduled_jobs != []
      end)

      assert :ok = Jobs.run_jobs(context.expires_at)

      assert_receive_event ReservationExpired, fn event ->
        assert event.ticket_uuid == context.ticket_uuid
      end
    end
  end

  defp reserve_ticket(_context) do
    ticket_uuid = UUID.uuid4()
    expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :second)

    reserve_ticket = %ReserveTicket{
      ticket_uuid: ticket_uuid,
      description: "Cinema ticket",
      price: 10.0,
      expires_at: expires_at,
    }

    :ok = TicketCompositeRouter.dispatch(reserve_ticket)

    [
      ticket_uuid: ticket_uuid,
      expires_at: expires_at,
    ]
  end
end
