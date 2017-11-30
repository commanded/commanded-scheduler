defmodule Commanded.DispatcherTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions

  alias Commanded.Scheduler.Dispatcher
  alias ExampleDomain.TicketBooking.Commands.TimeoutReservation
  alias ExampleDomain.TicketRouter
  alias ExampleDomain.TicketBooking.Commands.ReserveTicket
  alias ExampleDomain.TicketBooking.Events.ReservationExpired

  setup do
    Application.put_env(:commanded_scheduler, :router, TicketRouter)

    on_exit fn ->
      Application.put_env(:commanded_scheduler, :router, nil)
    end
  end

  describe "dispatcher" do
    setup [:reserve_ticket]

    test "should dispatch command", context do
      timeout = %TimeoutReservation{
        ticket_uuid: context.ticket_uuid,
      }

      assert :ok = Dispatcher.execute("timeout", timeout)

      assert_receive_event ReservationExpired, fn event ->
        assert event.ticket_uuid == context.ticket_uuid
      end
    end
  end

  defp reserve_ticket(_context) do
    ticket_uuid = UUID.uuid4()

    reserve_ticket = %ReserveTicket{
      ticket_uuid: ticket_uuid,
      description: "Cinema ticket",
      price: 10.0,
      expires_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :second),
    }

    :ok = TicketRouter.dispatch(reserve_ticket)

    [
      ticket_uuid: ticket_uuid,
    ]
  end
end
