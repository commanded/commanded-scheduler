defmodule Commanded.Scheduler do
  @moduledoc """
  One-off command scheduler for [Commanded][1] CQRS/ES applications.

  [1]: https://hex.pm/packages/commanded

  - [Getting started](getting-started.html)
  - [Usage](usage.html)

  """

  alias Commanded.Scheduler.{
    ScheduleBatch,
    CancelSchedule,
    Router,
    ScheduleOnce
  }

  @type schedule_uuid :: String.t()
  @type due_at :: DateTime.t() | NaiveDateTime.t()

  @doc """
  Schedule a uniquely identified one-off job using the given command to dispatch
  at the specified date/time.

  ## Example

      Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])

   Name the scheduled job:

      Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, due_at, name: "timeout")

  """
  @spec schedule_once(schedule_uuid, struct, due_at, name: String.t()) :: :ok | {:error, term}

  def schedule_once(schedule_uuid, command, due_at, opts \\ [])

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
  @spec cancel_schedule(schedule_uuid, name: String.t()) :: :ok | {:error, term}

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
