defmodule Commanded.Scheduler.ScheduleTriggered do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t()
        }

  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type
  ]
end

alias Commanded.Scheduler.{Convert, ScheduleTriggered}

defimpl Poison.Decoder, for: ScheduleTriggered do
  def decode(%ScheduleTriggered{} = triggered, _options) do
    %ScheduleTriggered{command: command, command_type: command_type} = triggered

    %ScheduleTriggered{
      triggered
      | command: Convert.to_struct(command_type, command)
    }
  end
end
