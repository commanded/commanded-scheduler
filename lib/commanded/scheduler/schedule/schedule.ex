defmodule Commanded.Scheduler.Schedule do
  @moduledoc false

  alias Commanded.Scheduler.{
    ScheduleElapsed,
    ScheduleOnce,
    ScheduledOnce,
    ScheduleRecurring,
    ScheduledRecurring,
    TriggerSchedule,
  }
  alias Commanded.Scheduler.Schedule

  defstruct [:schedule_uuid, :command, :command_type]

  # public API

  def execute(
    %Schedule{schedule_uuid: nil},
    %ScheduleOnce{command: command} = once)
  do
    struct(ScheduledOnce, Map.from_struct(once)) |> include_command_type(command)
  end

  def execute(%Schedule{}, %ScheduleOnce{}),
    do: {:error, :already_scheduled}

  def execute(
    %Schedule{schedule_uuid: nil},
    %ScheduleRecurring{command: command} = recurring)
  do
    struct(ScheduledRecurring, Map.from_struct(recurring)) |> include_command_type(command)
  end

  def execute(%Schedule{}, %ScheduleRecurring{}),
    do: {:error, :already_scheduled}

  def execute(
    %Schedule{schedule_uuid: schedule_uuid, command: command, command_type: command_type},
    %TriggerSchedule{schedule_uuid: schedule_uuid})
  do
    %ScheduleElapsed{
      schedule_uuid: schedule_uuid,
      command: command,
      command_type: command_type,
    }
  end

  # state mutators

  def apply(
    %Schedule{} = schedule,
    %ScheduledOnce{schedule_uuid: schedule_uuid, command: command, command_type: command_type})
  do
    %Schedule{schedule |
      schedule_uuid: schedule_uuid,
      command: command,
      command_type: command_type,
    }
  end

  def apply(
    %Schedule{} = schedule,
    %ScheduledRecurring{schedule_uuid: schedule_uuid, command: command, command_type: command_type})
  do
    %Schedule{schedule |
      schedule_uuid: schedule_uuid,
      command: command,
      command_type: command_type,
    }
  end

  # private helpers

  defp include_command_type(map, command) do
    Map.put(map, :command_type, Atom.to_string(command.__struct__))
  end
end
