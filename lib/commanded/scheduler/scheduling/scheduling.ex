defmodule Commanded.Scheduler.Scheduling do
  @moduledoc false
  use Commanded.Event.Handler,
    name: "Commanded.Scheduler.Scheduling"

  alias Commanded.Scheduler
  alias Commanded.Scheduler.{
    Dispatcher,
    ScheduleElapsed,
    ScheduledOnce,
    TriggerSchedule,
  }

  def handle(%ScheduledOnce{schedule_uuid: schedule_uuid, due_at: due_at}, _metadata) do
    trigger_schedule = %TriggerSchedule{schedule_uuid: schedule_uuid}

    Scheduler.schedule_once(schedule_uuid, Dispatcher, trigger_schedule, due_at)
  end

  def handle(%ScheduleElapsed{command: command}, _metadata) do
    router().dispatch(command)
  end

  def router do
    Application.get_env(:commanded_scheduler, :router) ||
      raise "Commanded scheduler expects `:router` to be defined in config"
  end
end
