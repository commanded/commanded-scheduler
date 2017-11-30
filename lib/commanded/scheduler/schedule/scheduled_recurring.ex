defmodule Commanded.Scheduler.ScheduledRecurring do
  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    command: struct(),
    command_type: String.t,
    schedule: String.t,
  }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :command,
    :command_type,
    :schedule,
  ]
end
