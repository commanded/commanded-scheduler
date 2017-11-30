defmodule Commanded.Scheduler.Dispatcher do
  @moduledoc false

  def execute(name, command) do
    router().dispatch(command)
  end

  defp router do
    Application.get_env(:commanded_scheduler, :router) ||
      raise "Commanded scheduler expects a `:router` to be defined in environment config"
  end
end
