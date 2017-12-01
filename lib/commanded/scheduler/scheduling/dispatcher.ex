defmodule Commanded.Scheduler.Dispatcher do
  @moduledoc false

  require Logger

  alias Commanded.Scheduler.{Router,TriggerSchedule}

  @behaviour Commanded.Scheduler.Job

  def execute(schedule_uuid, _args) do
    Logger.debug(fn -> "Attempting to trigger schedule #{inspect schedule_uuid}" end)

    trigger_schedule = %TriggerSchedule{
      schedule_uuid: schedule_uuid
    }

    Router.dispatch(trigger_schedule)
  end
end
