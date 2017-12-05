defmodule Commanded.Scheduler.ScheduledOnce do
  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    command: struct(),
    command_type: String.t,
    due_at: NaiveDateTime.t,
  }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :command,
    :command_type,
    :due_at,
  ]
end

defimpl Poison.Decoder, for: Commanded.Scheduler.ScheduledOnce do
  alias Commanded.Scheduler.ScheduledOnce

  def decode(%ScheduledOnce{command: command, command_type: command_type, due_at: due_at} = once, _options) do
    %ScheduledOnce{once |
      command: command_type |> String.to_existing_atom() |> struct(command),
      due_at: NaiveDateTime.from_iso8601!(due_at),
    }
  end
end
