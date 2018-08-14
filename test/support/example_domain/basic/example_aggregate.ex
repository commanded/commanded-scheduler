defmodule ExampleDomain.ExampleAggregate do
  alias ExampleDomain.ExampleAggregate

  defmodule Execute do
    defstruct [:aggregate_uuid, :data]
  end

  defmodule Error do
    defstruct [:aggregate_uuid, :reply_to, :error]
  end

  defmodule Raise do
    defstruct [:aggregate_uuid, :reply_to, :message]
  end

  defmodule Executed do
    defstruct [:data]
  end

  defstruct [:executed_at]

  def execute(%ExampleAggregate{}, %Execute{} = command) do
    %Execute{data: data} = command

    %Executed{data: data}
  end

  def execute(%ExampleAggregate{}, %Error{} = command) do
    %Error{reply_to: reply_to, error: error} = command

    pid = :erlang.list_to_pid(reply_to)

    send(pid, {:error, error})

    {:error, error}
  end

  def execute(%ExampleAggregate{}, %Raise{} = command) do
    %Raise{reply_to: reply_to, message: message} = command

    pid = :erlang.list_to_pid(reply_to)

    send(pid, {:exception, message})

    raise message
  end

  def apply(%ExampleAggregate{} = agg, _event), do: agg
end
