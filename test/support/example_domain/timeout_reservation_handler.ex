defmodule ExampleDomain.TimeoutReservationHandler do
  use Commanded.Event.Handler, name: __MODULE__

  alias Commanded.Scheduler.Commands.ScheduleOnce
  alias ExampleDomain.Router
  alias ExampleDomain.TicketBooking.Commands.TimeoutReservation
  alias ExampleDomain.TicketBooking.Events.TicketReserved

  def handle(
    %TicketReserved{ticket_uuid: ticket_uuid, expires_at: expires_at},
    _metadata)
  do
    timeout_reservation = %TimeoutReservation{
      ticket_uuid: ticket_uuid
    }

    schedule = %ScheduleOnce{
      schedule_uuid: ticket_uuid,
      command: timeout_reservation,
      due_at: expires_at,
    }

    Router.dispatch(schedule)
  end
end
