defmodule Commanded.Scheduler.ScheduleElapsed do
  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    command: struct(),
    command_type: String.t,
  }

  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :command,
    :command_type,
  ]
end
