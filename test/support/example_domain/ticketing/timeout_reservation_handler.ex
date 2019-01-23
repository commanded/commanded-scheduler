defmodule ExampleDomain.TimeoutReservationHandler do
  @moduledoc false

  use Commanded.Event.Handler, name: __MODULE__

  alias Commanded.Scheduler.ScheduleOnce
  alias ExampleDomain.AppRouter
  alias ExampleDomain.TicketBooking.Commands.TimeoutReservation
  alias ExampleDomain.TicketBooking.Events.TicketReserved

  @doc """
  Timeout the ticket reservation after the expiry date/time.
  """
  def handle(%TicketReserved{} = event, _metadata) do
    %TicketReserved{ticket_uuid: ticket_uuid, expires_at: expires_at} = event

    timeout_reservation = %TimeoutReservation{ticket_uuid: ticket_uuid}

    schedule_once = %ScheduleOnce{
      schedule_uuid: "schedule-" <> ticket_uuid,
      command: timeout_reservation,
      due_at: expires_at
    }

    AppRouter.dispatch(schedule_once)
  end
end
