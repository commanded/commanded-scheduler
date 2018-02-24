defmodule Commanded.Scheduler.Projection do
  @moduledoc false

  use Commanded.Projections.Ecto,
    name: "Commanded.Scheduler.Projection",
    repo: Commanded.Scheduler.Repo

  defmodule Schedule do
    use Ecto.Schema

    @primary_key false
    schema "schedules" do
      field :schedule_uuid, :string, primary_key: true
      field :name, :string, primary_key: true
      field :command, :map
      field :command_type, :string
      field :due_at, :naive_datetime
      field :schedule, :string

      timestamps()
    end
  end

  alias Commanded.Scheduler.{
    ScheduleCancelled,
    ScheduledOnce,
    ScheduledRecurring,
    ScheduleTriggered,
  }
  alias Commanded.Scheduler.Projection.Schedule

  project %ScheduledOnce{} = once do
    %ScheduledOnce{
      schedule_uuid: schedule_uuid,
      name: name,
      command: command,
      command_type: command_type,
      due_at: due_at
    } = once

    Ecto.Multi.insert(multi, :schedule_once, %Schedule{
      schedule_uuid: schedule_uuid,
      name: name,
      command: Map.from_struct(command),
      command_type: command_type,
      due_at: due_at,
    })
  end

  project %ScheduledRecurring{} = recurring do
    %ScheduledRecurring{
      schedule_uuid: schedule_uuid,
      name: name,
      command: command,
      command_type: command_type,
      schedule: schedule
    } = recurring

    Ecto.Multi.insert(multi, :schedule_once, %Schedule{
      schedule_uuid: schedule_uuid,
      name: name,
      command: Map.from_struct(command),
      command_type: command_type,
      schedule: schedule,
    })
  end

  project %ScheduleCancelled{schedule_uuid: schedule_uuid, name: name} do
    Ecto.Multi.delete_all(multi, :schedule, schedule_query(schedule_uuid, name))
  end

  project %ScheduleTriggered{schedule_uuid: schedule_uuid, name: name} do
    Ecto.Multi.delete_all(multi, :schedule, schedule_query(schedule_uuid, name))
  end

  defp schedule_query(schedule_uuid, name) do
    from s in Schedule,
    where: s.schedule_uuid == ^schedule_uuid and s.name == ^name
  end
end
