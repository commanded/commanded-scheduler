defmodule Commanded.Scheduler do
  @moduledoc """
  One-off and recurring command scheduler for
  [Commanded](https://hex.pm/packages/commanded) CQRS/ES applications.
  """

  alias Commanded.Scheduler.{
    Router,
    ScheduleOnce,
    ScheduleRecurring
  }

  @doc """
  Schedule a named one-off job using the given command to dispatch at the
  specified date/time.
  """
  @spec schedule_once(String.t(), struct, NaiveDateTime.t()) :: :ok
  def schedule_once(name, command, %NaiveDateTime{} = due_at)
      when is_bitstring(name) do
    schedule_once = %ScheduleOnce{
      schedule_uuid: name,
      command: command,
      due_at: due_at
    }

    Router.dispatch(schedule_once)
  end

  @doc """
  Schedule a named recurring job using the given command to dispatch repeatedly
  on the given schedule.

  Schedule supports the cron format where the minute, hour, day of month, month,
  and day of week (0 - 6, Sunday to Saturday) are specified. An example crontab
  schedule is "45 23 * * 6". It would trigger at 23:45 (11:45 PM) every Saturday.

  For more details please refer to https://en.wikipedia.org/wiki/Cron
  """
  @spec schedule_recurring(String.t(), struct, String.t()) :: :ok
  def schedule_recurring(name, command, schedule)
      when is_bitstring(name)
      when is_bitstring(schedule) do
    schedule_recurring = %ScheduleRecurring{
      schedule_uuid: name,
      command: command,
      schedule: schedule
    }

    Router.dispatch(schedule_recurring)
  end
end
