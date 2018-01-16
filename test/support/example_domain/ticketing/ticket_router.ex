defmodule ExampleDomain.TicketRouter do
  @moduledoc false
  
  use Commanded.Commands.Router

  alias ExampleDomain.TicketBooking
  alias ExampleDomain.TicketBooking.Commands.{ReserveTicket,TimeoutReservation}

  identify TicketBooking, by: :ticket_uuid
  dispatch [ReserveTicket,TimeoutReservation], to: TicketBooking
end
