defmodule Commanded.Scheduler.Batch do
  @moduledoc """
  Schedule a batch of one-off commands due at their given date/time (in UTC).
  """

  alias Commanded.Scheduler.ScheduleBatch

  def new(schedule_uuid) do
    %ScheduleBatch{schedule_uuid: schedule_uuid}
  end

  def schedule_once(%ScheduleBatch{} = batch, command, due_at, opts \\ []) do
    %ScheduleBatch{schedule_once: schedule_once} = batch

    once = %ScheduleBatch.Once{
      name: name(opts),
      command: command,
      due_at: due_at
    }

    %ScheduleBatch{batch | schedule_once: [once | schedule_once]}
  end

  def schedule_recurring(%ScheduleBatch{} = batch, command, cron_expression, opts \\ [])
      when is_bitstring(cron_expression) do
    %ScheduleBatch{schedule_recurring: schedule_recurring} = batch

    recurring = %ScheduleBatch.Recurring{
      name: name(opts),
      command: command,
      schedule: cron_expression
    }

    %ScheduleBatch{batch | schedule_recurring: [recurring | schedule_recurring]}
  end

  defp name(opts), do: Keyword.get(opts, :name)
end
