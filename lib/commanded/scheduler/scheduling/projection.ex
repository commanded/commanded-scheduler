defmodule Commanded.Scheduler.Projection do
  @moduledoc false

  use Commanded.Projections.Ecto,
    name: "Commanded.Scheduler.Projection",
    repo: Commanded.Scheduler.Repo

  defmodule Schedule do
    use Ecto.Schema

    @primary_key {:schedule_uuid, :string, []}
    schema "schedules" do
      field :command, :map
      field :command_type, :string
      field :due_at, :naive_datetime
      field :schedule, :string

      timestamps()
    end
  end

  alias Commanded.Scheduler.{
    ScheduledOnce,
    ScheduledRecurring,
    ScheduleElapsed,
  }
  alias Commanded.Scheduler.Projection.Schedule

  project %ScheduledOnce{} = once do
    Ecto.Multi.insert(multi, :schedule_once, %Schedule{
      schedule_uuid: once.schedule_uuid,
      command: Map.from_struct(once.command),
      command_type: once.command_type,
      due_at: once.due_at,
    })
  end

  project %ScheduledRecurring{} = recurring do
    Ecto.Multi.insert(multi, :schedule_once, %Schedule{
      schedule_uuid: recurring.schedule_uuid,
      command: Map.from_struct(recurring.command),
      command_type: recurring.command_type,
      schedule: recurring.schedule,
    })
  end

  project %ScheduleElapsed{schedule_uuid: schedule_uuid} do
    Ecto.Multi.delete_all(multi, :schedule, schedule_query(schedule_uuid))
  end

  defp schedule_query(schedule_uuid) do
    from s in Schedule,
    where: s.schedule_uuid == ^schedule_uuid
  end
end
