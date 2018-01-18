defmodule Commanded.Scheduler.ScheduledRecurring do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t(),
          schedule: String.t()
        }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type,
    :schedule
  ]
end

alias Commanded.Scheduler.{Convert, ScheduledRecurring}

defimpl Poison.Decoder, for: ScheduledRecurring do
  def decode(%ScheduledRecurring{} = recurring, _options) do
    %ScheduledRecurring{command: command, command_type: command_type} = recurring

    %ScheduledRecurring{
      recurring
      | command: Convert.to_struct(command_type, command)
    }
  end
end
