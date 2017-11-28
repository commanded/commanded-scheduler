defmodule Commanded.Scheduler.Router do
  @moduledoc false
  use Commanded.Commands.Router

  alias Commanded.Scheduler.{
    ScheduleOnce,
    ScheduleRecurring,
  }
  alias Commanded.Scheduler.Schedule

  identify Schedule, by: :schedule_uuid

  dispatch [ScheduleOnce, ScheduleRecurring], to: Schedule

  def schedule_prefix do
    Application.get_env(:commanded_scheduler, :schedule_prefix)
  end
end
