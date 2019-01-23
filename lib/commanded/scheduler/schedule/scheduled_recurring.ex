defmodule Commanded.Scheduler.ScheduledRecurring do
  @moduledoc false

  alias Commanded.Scheduler.Convert
  alias Commanded.Scheduler.ScheduledRecurring

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t(),
          schedule: String.t()
        }
  @derive Jason.Encoder
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type,
    :schedule
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%ScheduledRecurring{} = recurring) do
      %ScheduledRecurring{command: command, command_type: command_type} = recurring

      %ScheduledRecurring{
        recurring
        | command: Convert.to_struct(command_type, command)
      }
    end
  end
end
