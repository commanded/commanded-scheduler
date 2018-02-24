defmodule Commanded.Scheduler do
  @moduledoc """
  One-off and recurring command scheduler for
  [Commanded](https://hex.pm/packages/commanded) CQRS/ES applications.
  """

  alias Commanded.Scheduler.{
    ScheduleBatch,
    CancelSchedule,
    Router,
    ScheduleOnce,
    ScheduleRecurring
  }

  @type schedule :: String.t()
  @type due_at :: DateTime.t() | NaiveDateTime.t()

  @doc """
  Schedule a uniquely identified one-off job using the given command to dispatch
  at the specified date/time.

  ## Example

      Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])

   Name the scheduled job:

      Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, due_at, name: "timeout")

  """
  @spec schedule_once(schedule, struct, due_at, name: String.t()) :: :ok | {:error, term}

  def schedule_once(schedule, command, due_at, opts \\ [])

  def schedule_once(schedule_uuid, command, due_at, opts)
      when is_bitstring(schedule_uuid) do
    schedule_once = %ScheduleOnce{
      schedule_uuid: schedule_uuid,
      name: name(opts),
      command: command,
      due_at: due_at
    }

    Router.dispatch(schedule_once)
  end

  @doc """
  Schedule a uniquely identified recurring job using the given command to
  dispatch repeatedly on the given schedule.

  Schedule supports the cron format where the minute, hour, day of month, month,
  and day of week (0 - 6, Sunday to Saturday) are specified. An example crontab
  schedule is "45 23 * * 6". It would trigger at 23:45 (11:45 PM) every Saturday.

  For more details please refer to https://en.wikipedia.org/wiki/Cron

  ## Example

  Schedule a job to run every 15 minutes:

      Scheduler.schedule_recurring(reservation_id, %TimeoutReservation{..}, "*/15 * * * *")

  Name the recurring job that runs every day at midnight:

      Scheduler.schedule_recurring(reservation_id, %TimeoutReservation{..}, "@daily", name: "timeout")

  """
  @spec schedule_recurring(schedule, struct, String.t(), name: String.t()) :: :ok | {:error, term}

  def schedule_recurring(schedule, command, cron_expression, opts \\ [])

  def schedule_recurring(schedule_uuid, command, cron_expression, opts)
      when is_bitstring(schedule_uuid) and is_bitstring(cron_expression) do
    schedule_recurring = %ScheduleRecurring{
      schedule_uuid: schedule_uuid,
      name: name(opts),
      command: command,
      schedule: cron_expression
    }

    Router.dispatch(schedule_recurring)
  end

  @doc """
  Schedule multiple one-off commands in a single batch.

  This guarantees that all, or none, of the commands are scheduled.

  ## Example

      alias Commanded.Scheduler
      alias Commanded.Scheduler.Batch

      batch =
        reservation_id
        |> Batch.new()
        |> Batch.schedule_once(%TimeoutReservation{..}, timeout_due_at, name: "timeout")
        |> Batch.schedule_once(%ReleaseSeat{..}, release_due_at, name: "release")

      Scheduler.schedule_batch(batch)

  """
  @spec schedule_batch(ScheduleBatch.t()) :: :ok | {:error, term}

  def schedule_batch(%ScheduleBatch{} = batch) do
    Router.dispatch(batch)
  end

  @doc """
  Cancel a one-off or recurring schedule.
  """
  @spec cancel_schedule(String.t(), name: String.t()) :: :ok | {:error, term}

  def cancel_schedule(schedule_uuid, opts \\ [])

  def cancel_schedule(schedule_uuid, opts)
      when is_bitstring(schedule_uuid) do
    cancel_schedule = %CancelSchedule{
      schedule_uuid: schedule_uuid,
      name: Keyword.get(opts, :name)
    }

    Router.dispatch(cancel_schedule)
  end

  defp name(opts), do: Keyword.get(opts, :name)
end
