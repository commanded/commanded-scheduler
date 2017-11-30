defmodule Commanded.Scheduler do
  @moduledoc """
  One-off and recurring command scheduler for
  [Commanded](https://hex.pm/packages/commanded) CQRS/ES applications.
  """

  alias Commanded.Scheduler.Jobs

  @doc """
  Schedule a named one-off job using the given module, function, args to run at
  the specified date/time.
  """
  @spec schedule_once(name :: any, module :: atom, args :: any, run_at :: NaiveDateTime.t) :: :ok
  def schedule_once(name, module, args, %NaiveDateTime{} = run_at)
    when is_atom(module)
  do
    Jobs.schedule_once(name, module, args, run_at)
  end

  @doc """
  Schedule a named recurring job using the given module, function, args to run
  repeatedly on the given schedule.
  """
  @spec schedule_recurring(name :: any, module :: atom, args :: any, schedle :: String.t) :: :ok
  def schedule_recurring(name, module, args, schedule)
    when is_atom(module)
    when is_bitstring(schedule)
  do
    Jobs.schedule_recurring(name, module, args, schedule)
  end
end
