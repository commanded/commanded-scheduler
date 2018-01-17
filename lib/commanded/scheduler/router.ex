defmodule Commanded.Scheduler.Router do
  @moduledoc false

  use Commanded.Commands.Router

  alias Commanded.Scheduler.{
    CancelSchedule,
    Router,
    ScheduleBatch,
    ScheduleOnce,
    ScheduleRecurring,
    TriggerSchedule,
  }
  alias Commanded.Scheduler.Schedule

  identify Schedule,
    by: :schedule_uuid,
    prefix: &Router.schedule_prefix/0

  dispatch [
    CancelSchedule,
    ScheduleBatch,
    ScheduleOnce,
    ScheduleRecurring,
    TriggerSchedule,
  ], to: Schedule

  def schedule_prefix do
    Application.get_env(:commanded_scheduler, :schedule_prefix) || ""
  end
end
