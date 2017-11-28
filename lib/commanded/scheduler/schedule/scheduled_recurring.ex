defmodule Commanded.Scheduler.ScheduledRecurring do
  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    cancellation_token: String.t | nil,
    command: struct(),
    command_type: String.t,
    schedule: String.t,
  }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :cancellation_token,
    :command,
    :command_type,
    :schedule,
  ]
end
