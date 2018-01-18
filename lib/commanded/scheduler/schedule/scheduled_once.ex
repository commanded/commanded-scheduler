defmodule Commanded.Scheduler.ScheduledOnce do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t(),
          due_at: NaiveDateTime.t()
        }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type,
    :due_at
  ]
end

alias Commanded.Scheduler.{Convert, ScheduledOnce}

defimpl Poison.Decoder, for: ScheduledOnce do
  def decode(%ScheduledOnce{} = once, _options) do
    %ScheduledOnce{command: command, command_type: command_type, due_at: due_at} = once

    %ScheduledOnce{
      once
      | command: Convert.to_struct(command_type, command),
        due_at: NaiveDateTime.from_iso8601!(due_at)
    }
  end
end
