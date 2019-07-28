defmodule JsonbSerializer do
  @moduledoc """
  Serialize to/from PostgreSQL's native `jsonb` format.
  """

  @behaviour EventStore.Serializer

  alias Commanded.EventStore.TypeProvider
  alias Commanded.Serialization.JsonDecoder

  def serialize(%_{} = term) do
    for {key, value} <- Map.from_struct(term), into: %{} do
      {Atom.to_string(key), value}
    end
  end

  def serialize(term), do: term

  def deserialize(term, config) do
    case Keyword.get(config, :type) do
      nil ->
        term

      type ->
        type
        |> TypeProvider.to_struct()
        |> to_struct(term)
        |> JsonDecoder.decode()
    end
  end

  def to_struct(type, term) do
    struct(type, keys_to_atoms(term))
  end

  defp keys_to_atoms(map) when is_map(map) do
    for {key, value} <- map, into: %{} do
      {String.to_atom(key), keys_to_atoms(value)}
    end
  end

  defp keys_to_atoms(value), do: value
end
