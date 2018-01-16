defmodule ExampleDomain.ExampleAggregate do
  alias ExampleDomain.ExampleAggregate

  defmodule Execute do
    defstruct [:aggregate_uuid, :data]
  end

  defmodule Executed do
    defstruct [:data]
  end

  defstruct [:executed_at]

  def execute(%ExampleAggregate{}, %Execute{data: data}) do
    %Executed{data: data}
  end

  def apply(%ExampleAggregate{} = agg, _event), do: agg
end
