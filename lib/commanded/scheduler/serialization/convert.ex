defmodule Commanded.Scheduler.Convert do
  @moduledoc false

  @doc """
  Convert deserialized map, containing string keys, into its target struct.
  """
  def to_struct(type, map)

  def to_struct(type, map)
      when is_bitstring(type) and is_map(map) do
    type |> String.to_existing_atom() |> to_struct(map)
  end

  def to_struct(type, map)
      when is_atom(type) and is_map(map) do
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
