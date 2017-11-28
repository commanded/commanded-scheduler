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
  def schedule_once(name, {module, function, args}, %NaiveDateTime{} = run_at)
    when is_atom(module)
    when is_function(function)
    when is_list(args)
  do
    Jobs.schedule_once(name, {module, function, args}, run_at)
  end

  @doc """
  Schedule a named recurring job using the given module, function, args to run
  repeatedly on the given schedule.
  """
  def schedule_recurring(name, {module, function, args}, schedule)
    when is_atom(module)
    when is_function(function)
    when is_list(args)
    when is_bitstring(schedule)
  do
    Jobs.schedule_recurring(name, {module, function, args}, schedule)
  end
end
