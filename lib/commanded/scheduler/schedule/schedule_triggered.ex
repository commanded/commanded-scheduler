defmodule Commanded.Scheduler.ScheduleTriggered do
  @moduledoc false
  alias Commanded.Scheduler.{Convert, ScheduleTriggered}

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%ScheduleTriggered{} = triggered) do
      %ScheduleTriggered{command: command, command_type: command_type} = triggered

      %ScheduleTriggered{
        triggered
        | command: Convert.to_struct(command_type, command)
      }
    end
  end
end
