defmodule Commanded.Scheduler.ScheduledOnce do
  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    command: struct(),
    command_type: String.t,
    due_at: NaiveDateTime.t,
  }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :command,
    :command_type,
    :due_at,
  ]
end
