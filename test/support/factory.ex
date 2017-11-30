defmodule Commanded.Scheduler.Factory do
  alias Commanded.Scheduler.ExampleCommand
  alias Commanded.Scheduler.{ScheduleOnce,ScheduleRecurring}
  alias Commanded.Scheduler.Router

  def schedule_once(_context) do
    schedule_uuid = UUID.uuid4()
    aggregate_uuid = UUID.uuid4()
    due_at = NaiveDateTime.utc_now()
    command = %ExampleCommand{
      aggregate_uuid: aggregate_uuid,
      data: "example",
    }
    schedule_once = %ScheduleOnce{
      schedule_uuid: schedule_uuid,
      command: command,
      due_at: due_at,
    }

    :ok = Router.dispatch(schedule_once)

    [
      schedule_uuid: schedule_uuid,
      aggregate_uuid: aggregate_uuid,
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
end
