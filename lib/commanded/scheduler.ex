defmodule Commanded.Scheduler do
  @moduledoc """
  One-off and recurring command scheduler for
  [Commanded](https://hex.pm/packages/commanded) CQRS/ES applications.
  """

  alias Commanded.Scheduler.{
    CancelSchedule,
    Router,
    ScheduleBatch,
    ScheduleOnce,
    ScheduleRecurring
  }

  @type schedule :: String.t() | ScheduleBatch.t()

  @doc """
  Schedule a uniquely identified one-off job using the given command to dispatch
  at the specified date/time.

  ## Example

      Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])

   Name the scheduled job:

      Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, due_at, name: "timeout")

  """
  @spec schedule_once(schedule, struct, NaiveDateTime.t(), name: String.t()) ::
          :ok | {:error, term}

  def schedule_once(schedule, command, due_at, opts \\ [])

  def schedule_once(schedule_uuid, command, %NaiveDateTime{} = due_at, opts)
      when is_bitstring(schedule_uuid) do
    schedule_once = %ScheduleOnce{
      schedule_uuid: schedule_uuid,
      name: name(opts),
      command: command,
      due_at: due_at
    }

    Router.dispatch(schedule_once)
  end

  def schedule_once(%ScheduleBatch{} = batch, command, %NaiveDateTime{} = due_at, opts) do
    %ScheduleBatch{schedule_once: schedule_once} = batch

    once = %ScheduleBatch.Once{
      name: name(batch, opts),
      command: command,
      due_at: due_at
    }

    %ScheduleBatch{batch | schedule_once: [once | schedule_once]}
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
      when is_bitstring(schedule_uuid)
      when is_bitstring(cron_expression) do
    schedule_recurring = %ScheduleRecurring{
      schedule_uuid: schedule_uuid,
      name: name(opts),
      command: command,
      schedule: cron_expression
    }

    Router.dispatch(schedule_recurring)
  end

  def schedule_recurring(%ScheduleBatch{} = batch, command, cron_expression, opts)
      when is_bitstring(cron_expression) do
    %ScheduleBatch{schedule_recurring: schedule_recurring} = batch

    recurring = %ScheduleBatch.Recurring{
      name: name(batch, opts),
      command: command,
      schedule: cron_expression
    }

    %ScheduleBatch{batch | schedule_recurring: [recurring | schedule_recurring]}
  end

  @doc """
  Schedule multiple one-off commands in a single batch.

  This guarantees that all, or none, of the commands are scheduled.

  ## Example

      Scheduler.batch(reservation_id, fn batch ->
        batch
        |> Scheduler.schedule_once(%TimeoutReservation{..}, timeout_due_at, name: "timeout")
        |> Scheduler.schedule_once(%ReleaseSeat{..}, release_due_at, name: "release")
      end)

  """
  @spec batch(String.t(), (ScheduleBatch.t() -> ScheduleBatch.t())) :: :ok | {:error, term}

  def batch(schedule_uuid, batch_fn)
      when is_bitstring(schedule_uuid)
      when is_function(batch_fn) do
    %ScheduleBatch{} = schedule_batch = batch_fn.(%ScheduleBatch{schedule_uuid: schedule_uuid})

    Router.dispatch(schedule_batch)
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

  defp name(opts), do: Keyword.get(opts, :name, "@default")

  defp name(%ScheduleBatch{} = batch, opts) do
    %ScheduleBatch{
      schedule_once: schedule_once,
      schedule_recurring: schedule_recurring
    } = batch

    Keyword.get(opts, :name, "@default#{length(schedule_once) + length(schedule_recurring)}")
  end
end
