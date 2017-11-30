defmodule Commanded.Scheduler.Dispatcher do
  @moduledoc false

  require Logger

  @behaviour Commanded.Scheduler.Job

  def execute(_name, command) do
    Logger.debug(fn -> "Attempting to dispatch scheduled command: #{inspect command}" end)

    router().dispatch(command)
  end

  defp router do
    Application.get_env(:commanded_scheduler, :router) ||
      raise "Commanded scheduler expects a `:router` to be defined in environment config"
  end
end
