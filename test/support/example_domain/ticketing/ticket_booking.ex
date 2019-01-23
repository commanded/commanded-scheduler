defmodule ExampleDomain.TicketBooking do
  @moduledoc false

  defmodule Commands do
    defmodule ReserveTicket do
      @derive Jason.Encoder
      defstruct [:ticket_uuid, :description, :price, :expires_at]
    end

    defmodule TimeoutReservation do
      @derive Jason.Encoder
      defstruct [:ticket_uuid]
    end
  end

  defmodule Events do
    defmodule TicketReserved do
      @derive Jason.Encoder
      defstruct [:ticket_uuid, :description, :price, :expires_at]
    end

    defmodule ReservationExpired do
      @derive Jason.Encoder
      defstruct [:ticket_uuid]
    end
  end

  defstruct [:ticket_uuid, :expires_at, :status]

  alias ExampleDomain.TicketBooking
  alias ExampleDomain.TicketBooking.Commands.{ReserveTicket, TimeoutReservation}
  alias ExampleDomain.TicketBooking.Events.{ReservationExpired, TicketReserved}

  def execute(%TicketBooking{ticket_uuid: nil}, %ReserveTicket{} = reserve_ticket) do
    struct(TicketReserved, Map.from_struct(reserve_ticket))
  end

  def execute(%TicketBooking{status: :pending}, %TimeoutReservation{} = timeout) do
    struct(ReservationExpired, Map.from_struct(timeout))
  end

  def execute(%TicketBooking{status: status}, %TimeoutReservation{})
      when status in [:expired, :paid] do
    []
  end

  def apply(%TicketBooking{} = booking, %TicketReserved{} = event) do
    %TicketReserved{ticket_uuid: ticket_uuid, expires_at: expires_at} = event

    %TicketBooking{booking | ticket_uuid: ticket_uuid, expires_at: expires_at, status: :pending}
  end

  def apply(%TicketBooking{} = booking, %ReservationExpired{}) do
    %TicketBooking{booking | status: :expired}
  end
end
