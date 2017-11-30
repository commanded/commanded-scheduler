defmodule Commanded.Scheduler.Schedule do
  @moduledoc false

  alias Commanded.Scheduler.{
    ScheduleOnce,
    ScheduledOnce,
    ScheduleRecurring,
    ScheduledRecurring,
  }
  alias Commanded.Scheduler.Schedule

  defstruct [:schedule_uuid]

  # public API

  def execute(%Schedule{schedule_uuid: nil}, %ScheduleOnce{command: command} = once) do
    struct(ScheduledOnce, Map.from_struct(once)) |> include_command_type(command)
  end

  def execute(%Schedule{}, %ScheduleOnce{}),
    do: {:error, :already_scheduled}

  def execute(%Schedule{schedule_uuid: nil}, %ScheduleRecurring{command: command} = recurring) do
    struct(ScheduledRecurring, Map.from_struct(recurring)) |> include_command_type(command)
  end

  def execute(%Schedule{}, %ScheduleRecurring{}),
    do: {:error, :already_scheduled}

  # state mutators

  def apply(
    %Schedule{} = schedule,
    %ScheduledOnce{schedule_uuid: schedule_uuid})
  do
    %Schedule{schedule | schedule_uuid: schedule_uuid}
  end

  def apply(
    %Schedule{} = schedule,
    %ScheduledRecurring{schedule_uuid: schedule_uuid})
  do
    %Schedule{schedule | schedule_uuid: schedule_uuid}
  end

  # private helpers

  defp include_command_type(map, command) do
    Map.put(map, :command_type, Atom.to_string(command.__struct__))
  end
end
