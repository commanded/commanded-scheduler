defmodule Commanded.Scheduler.JobScheduler do
  @moduledoc false

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

  use Commanded.Projections.Ecto,
    name: "Commanded.Scheduler",
    repo: Commanded.Scheduler.Repo

  alias Commanded.Scheduler
  alias Commanded.Scheduler.{Dispatcher,ScheduledOnce,ScheduledRecurring}
  alias Commanded.Scheduler.JobScheduler.Schedule

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

  def after_update(%ScheduledOnce{} = once, _metadata, _changes) do
    Scheduler.schedule_once(once.schedule_uuid, Dispatcher, once.command, once.due_at)
  end

  def after_update(_event, _metadata, _changes), do: :ok
end
