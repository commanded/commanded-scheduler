defmodule Commanded.Scheduler.Schedule do
  @moduledoc false

  alias Commanded.Scheduler.{
    CancelSchedule,
    ScheduleBatch,
    ScheduleCancelled,
    ScheduledOnce,
    ScheduledRecurring,
    ScheduleOnce,
    ScheduleRecurring,
    ScheduleTriggered,
    TriggerSchedule
  }

  alias Commanded.Scheduler.Schedule
  alias Commanded.Aggregate.Multi

  defstruct [
    :schedule_uuid,
    scheduled: %{}
  ]

  # public API

  # Schedule a one-off command
  def execute(%Schedule{schedule_uuid: nil} = schedule, %ScheduleOnce{} = once) do
    schedule_once(schedule, Map.from_struct(once))
  end

  def execute(%Schedule{}, %ScheduleOnce{}), do: {:error, :already_scheduled}

  # Schedule a recurring command
  def execute(%Schedule{schedule_uuid: nil} = schedule, %ScheduleRecurring{} = recurring) do
    schedule_recurring(schedule, Map.from_struct(recurring))
  end

  def execute(%Schedule{}, %ScheduleRecurring{}), do: {:error, :already_scheduled}

  # Schedule a batch of commands
  def execute(%Schedule{schedule_uuid: nil} = schedule, %ScheduleBatch{} = batch) do
    %ScheduleBatch{
      schedule_uuid: schedule_uuid,
      schedule_once: schedule_once,
      schedule_recurring: schedule_recurring
    } = batch

    multi = Multi.new(schedule)

    multi =
      schedule_once
      |> Enum.map(fn once ->
        once |> Map.from_struct() |> Map.put(:schedule_uuid, schedule_uuid)
      end)
      |> Enum.reduce(multi, fn once, multi ->
        Multi.execute(multi, &schedule_once(&1, once))
      end)

    multi =
      schedule_recurring
      |> Enum.map(fn recurring ->
        recurring |> Map.from_struct() |> Map.put(:schedule_uuid, schedule_uuid)
      end)
      |> Enum.reduce(multi, fn recurring, multi ->
        Multi.execute(multi, &schedule_recurring(&1, recurring))
      end)

    multi
  end

  def execute(%Schedule{}, %ScheduleBatch{}), do: {:error, :already_scheduled}

  def execute(%Schedule{schedule_uuid: nil}, %TriggerSchedule{}), do: {:error, :no_schedule}

  # Trigger a scheduled command
  def execute(%Schedule{} = schedule, %TriggerSchedule{name: name}) do
    %Schedule{schedule_uuid: schedule_uuid, scheduled: scheduled} = schedule

    case Map.get(scheduled, name) do
      nil ->
        {:error, :no_schedule}

      {command, command_type} ->
        %ScheduleTriggered{
          schedule_uuid: schedule_uuid,
          name: name,
          command: command,
          command_type: command_type
        }
    end
  end

  def execute(%Schedule{schedule_uuid: nil}, %CancelSchedule{}), do: {:error, :no_schedule}

  # Cancel all scheduled commands
  def execute(%Schedule{scheduled: scheduled} = schedule, %CancelSchedule{name: nil}) do
    scheduled
    |> Map.keys()
    |> case do
      [] ->
        {:error, :no_schedule}

      names ->
        Enum.reduce(names, Multi.new(schedule), fn name, multi ->
          Multi.execute(multi, &cancel(&1, name))
        end)
    end
  end

  # Cancel named scheduled command
  def execute(%Schedule{} = schedule, %CancelSchedule{name: name}), do: cancel(schedule, name)

  # state mutators

  def apply(%Schedule{scheduled: scheduled} = schedule, %ScheduledOnce{} = once) do
    %ScheduledOnce{
      schedule_uuid: schedule_uuid,
      name: name,
      command: command,
      command_type: command_type
    } = once

    %Schedule{
      schedule
      | schedule_uuid: schedule_uuid,
        scheduled: Map.put(scheduled, name, {command, command_type})
    }
  end

  def apply(%Schedule{scheduled: scheduled} = schedule, %ScheduledRecurring{} = recurring) do
    %ScheduledRecurring{
      schedule_uuid: schedule_uuid,
      name: name,
      command: command,
      command_type: command_type
    } = recurring

    %Schedule{
      schedule
      | schedule_uuid: schedule_uuid,
        scheduled: Map.put(scheduled, name, {command, command_type})
    }
  end

  def apply(%Schedule{scheduled: scheduled} = schedule, %ScheduleTriggered{name: name}) do
    %Schedule{schedule | scheduled: Map.delete(scheduled, name)}
  end

  def apply(%Schedule{scheduled: scheduled} = schedule, %ScheduleCancelled{name: name}) do
    %Schedule{schedule | scheduled: Map.delete(scheduled, name)}
  end

  # private helpers

  defp schedule_once(%Schedule{} = schedule, once) when is_map(once) do
    schedule(schedule, ScheduledOnce, once)
  end

  defp schedule_recurring(%Schedule{} = schedule, recurring) when is_map(recurring) do
    schedule(schedule, ScheduledRecurring, recurring)
  end

  defp schedule(%Schedule{} = schedule, schedule_type, once_or_recurring) do
    with {:ok, name} <- ensure_default_name(schedule, once_or_recurring),
         :ok <- validate_scheduled(schedule, name) do
      schedule_type
      |> struct(once_or_recurring)
      |> Map.put(:name, name)
      |> Map.put(:command_type, command_type(once_or_recurring))
    else
      reply -> reply
    end
  end

  # Ensure a valid schedule name is provided, or set a default if `nil`.
  defp ensure_default_name(%Schedule{scheduled: scheduled}, schedule) do
    case Map.get(schedule, :name) do
      nil ->
        # use a default name (e.g. `@default0`)
        {:ok, "@default#{scheduled |> Map.keys() |> length()}"}

      name when is_bitstring(name) ->
        case String.length(name) do
          0 -> {:error, :invalid_schedule}
          _ -> {:ok, name}
        end

      _ ->
        {:error, :invalid_schedule}
    end
  end

  # Ensure the schedule name is unique
  defp validate_scheduled(%Schedule{scheduled: scheduled}, name) do
    case Map.has_key?(scheduled, name) do
      true ->
        {:error, :already_scheduled}

      false ->
        :ok
    end
  end

  defp command_type(%{command: command} = schedule) when is_map(schedule) do
    Atom.to_string(command.__struct__)
  end

  defp cancel(%Schedule{} = schedule, name) do
    %Schedule{schedule_uuid: schedule_uuid, scheduled: scheduled} = schedule

    case Map.get(scheduled, name) do
      nil ->
        {:error, :no_schedule}

      _ ->
        %ScheduleCancelled{
          schedule_uuid: schedule_uuid,
          name: name
        }
    end
  end
end
