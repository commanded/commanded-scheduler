defmodule Commanded.Scheduler.Factory do
  @moduledoc false
  
  alias Commanded.Scheduler.ExampleCommand
  alias Commanded.Scheduler.{ScheduleOnce,ScheduleRecurring,TriggerSchedule}
  alias Commanded.Scheduler.Router
  alias ExampleDomain.TicketBooking.Commands.{ReserveTicket,TimeoutReservation}
  alias ExampleDomain.TicketRouter

  def schedule_once(context) do
    schedule_uuid = UUID.uuid4()
    ticket_uuid = Map.get(context, :ticket_uuid, UUID.uuid4())
    due_at = NaiveDateTime.utc_now()
    command = %TimeoutReservation{
      ticket_uuid: ticket_uuid
    }
    schedule_once = %ScheduleOnce{
      schedule_uuid: schedule_uuid,
      command: command,
      due_at: due_at,
    }

    :ok = Router.dispatch(schedule_once)

    [
      schedule_uuid: schedule_uuid,
      ticket_uuid: ticket_uuid,
      due_at: due_at,
      command: command,
    ]
  end

  def schedule_recurring(_context) do
    schedule_uuid = UUID.uuid4()
    aggregate_uuid = UUID.uuid4()
    schedule = "@daily"

    command = %ExampleCommand{
      aggregate_uuid: aggregate_uuid,
      data: "example",
    }
    schedule_recurring = %ScheduleRecurring{
      schedule_uuid: schedule_uuid,
      command: command,
      schedule: schedule,
    }

    :ok = Router.dispatch(schedule_recurring)

    [
      schedule_uuid: schedule_uuid,
      aggregate_uuid: aggregate_uuid,
      command: command,
      schedule: schedule,
    ]
  end

  def trigger_schedule(context) do
    trigger_schedule = %TriggerSchedule{schedule_uuid: context.schedule_uuid}

    :ok = Router.dispatch(trigger_schedule)

    []
  end

  def reserve_ticket(context) do
    ticket_uuid = Map.get(context, :ticket_uuid, UUID.uuid4())
    expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :second)

    reserve_ticket = %ReserveTicket{
      ticket_uuid: ticket_uuid,
      description: "Cinema ticket",
      price: 10.0,
      expires_at: expires_at,
    }

    :ok = TicketRouter.dispatch(reserve_ticket)

    [
      ticket_uuid: ticket_uuid,
      expires_at: expires_at,
    ]
  end
end
