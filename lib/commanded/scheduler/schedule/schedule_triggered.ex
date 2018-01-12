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

alias Commanded.Scheduler.ScheduleTriggered

defimpl Poison.Decoder, for: ScheduleTriggered do
  def decode(%ScheduleTriggered{command: command, command_type: command_type} = elapsed, _options) do
    %ScheduleTriggered{
      elapsed
      | command: command_type |> String.to_existing_atom() |> to_struct(command)
    }
  end

  # Convert deserialized map, containing string keys, into its target struct.
  defp to_struct(type, map) do
    struct = struct(type)

    struct
    |> Map.to_list()
    |> Enum.reduce(struct, fn {k, _}, acc ->
      case Map.fetch(map, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
