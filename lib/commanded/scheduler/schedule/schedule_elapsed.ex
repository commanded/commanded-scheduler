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

defimpl Poison.Decoder, for: Commanded.Scheduler.ScheduleElapsed do
  alias Commanded.Scheduler.ScheduleElapsed

  def decode(%ScheduleElapsed{command: command, command_type: command_type} = elapsed, _options) do
    %ScheduleElapsed{elapsed |
      command: command_type |> String.to_existing_atom() |> struct(command),
    }
  end
end
