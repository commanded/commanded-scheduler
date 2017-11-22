defmodule Commanded.Scheduler.Events.ScheduledOnce do
  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    cancellation_token: String.t | nil,
    command: struct(),
    command_type: String.t,
    due_at: NaiveDateTime.t,
  }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :cancellation_token,
    :command,
    :command_type,
    :due_at,
  ]
end
