defmodule Commanded.Scheduler.Schedule do
  alias Commanded.Scheduler.Commands.{
    ScheduleOnce,
    ScheduleRecurring,
  }
  alias Commanded.Scheduler.Events.{
    ScheduledOnce,
    ScheduledRecurring,
  }
  alias Commanded.Scheduler.Schedule

  defstruct [
    schedule_uuid: nil,
    scheduled: [],
  ]

  defmodule OneOffSchedule do
    defstruct [
      :cancellation_token,
      :command,
      :due_at
    ]
  end

  defmodule RecurringSchedule do
    defstruct [
      :cancellation_token,
      :command,
      :due_at
    ]
  end

  # public API

  def execute(%Schedule{}, %ScheduleOnce{command: command} = once) do
    struct(ScheduledOnce, Map.from_struct(once)) |> include_command_type(command)
  end

  def execute(%Schedule{}, %ScheduleRecurring{command: command} = recurring) do
    struct(ScheduledRecurring, Map.from_struct(recurring)) |> include_command_type(command)
  end

  # state mutators

  def apply(
    %Schedule{scheduled: scheduled} = schedule,
    %ScheduledOnce{schedule_uuid: schedule_uuid} = once
  ) do
    %Schedule{schedule |
      schedule_uuid: schedule_uuid,
      scheduled: [struct(OneOffSchedule, Map.from_struct(once)) | scheduled],
    }
  end

  def apply(
    %Schedule{scheduled: scheduled} = schedule,
    %ScheduledRecurring{schedule_uuid: schedule_uuid} = recurring
  ) do
    %Schedule{schedule |
      schedule_uuid: schedule_uuid,
      scheduled: [struct(RecurringSchedule, Map.from_struct(recurring)) | scheduled],
    }
  end

  # private helpers

  defp include_command_type(map, command) do
    Map.put(map, :command_type, Atom.to_string(command.__struct__))
  end
end
