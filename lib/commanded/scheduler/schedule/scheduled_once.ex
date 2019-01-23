defmodule Commanded.Scheduler.ScheduledOnce do
  @moduledoc false
  alias Commanded.Scheduler.{Convert, ScheduledOnce}

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t(),
          due_at: NaiveDateTime.t()
        }
  @derive Jason.Encoder
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type,
    :due_at
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%ScheduledOnce{} = once) do
      %ScheduledOnce{command: command, command_type: command_type, due_at: due_at} = once

      %ScheduledOnce{
        once
        | command: Convert.to_struct(command_type, command),
          due_at: NaiveDateTime.from_iso8601!(due_at)
      }
    end
  end
end
