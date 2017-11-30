defmodule Commanded.Scheduler.JobScheduler do
  @moduledoc false

  defmodule Schedule do
    use Ecto.Schema

    @primary_key {:schedule_uuid, :string, []}
    schema "schedules" do
      field :cancellation_token, :string
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

  alias Commanded.Scheduler.JobScheduler.Schedule
  alias Commanded.Scheduler.{ScheduledOnce,ScheduledRecurring}

  project %ScheduledOnce{} = once do
    Ecto.Multi.insert(multi, :schedule_once, %Schedule{
      schedule_uuid: once.schedule_uuid,
      cancellation_token: once.cancellation_token,
      command: Map.from_struct(once.command),
      command_type: once.command_type,
      due_at: once.due_at,
    })
  end

  project %ScheduledRecurring{} = recurring do
    Ecto.Multi.insert(multi, :schedule_once, %Schedule{
      schedule_uuid: recurring.schedule_uuid,
      cancellation_token: recurring.cancellation_token,
      command: Map.from_struct(recurring.command),
      command_type: recurring.command_type,
      schedule: recurring.schedule,
    })
  end

  def after_update(_event, _metadata, _changes) do
    :ok
  end
end
