defmodule ExampleDomain.Router do
  use Commanded.Commands.Router

  alias ExampleDomain.TicketBooking
  alias ExampleDomain.TicketBooking.Commands.ReserveTicket

  identify TicketBooking, by: :ticket_uuid
  dispatch [ReserveTicket], to: TicketBooking
end
