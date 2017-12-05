defmodule Commanded.Scheduler.Dispatcher do
  @moduledoc false

  require Logger

  alias Commanded.Scheduler.Router

  @behaviour Commanded.Scheduler.Job

  def execute(schedule_uuid, command) do
    Logger.debug(fn -> "Attempting to trigger schedule #{inspect schedule_uuid}" end)
    
    Router.dispatch(command)
  end
end
