defmodule Commanded.Scheduler.Job do
  use GenServer

  require Logger

  alias Commanded.Scheduler.Job

  @callback execute(name :: any, args :: any) :: :ok

  defstruct [
    :name,
    :module,
    :args,
    retries: 0,
  ]

  def start_link(name, module, args) do
    GenServer.start_link(__MODULE__, %Job{name: name, module: module, args: args})
  end

  def init(%Job{} = state) do
    send(self(), :execute)

    {:ok, state}
  end

  def handle_info(:execute, %Job{name: name, module: module, args: args} = state) do
    task = Task.Supervisor.async_nolink(Commanded.Scheduler.JobRunner, module, :execute, [name, args])
    timeout = job_timeout()

    result =
      case Task.yield(task, timeout) || Task.shutdown(task) do
        {:ok, result} -> result
        {:exit, reason} -> {:error, reason}
        nil -> {:error, :timeout}
    end

    case result do
      :ok ->
        Logger.debug(fn -> describe(state) <> " completed" end)
        {:stop, :shutdown, state}

      {:error, reason} ->
        Logger.warn(fn -> describe(state) <> " failed due to: #{inspect reason}" end)
        retry(state)
    end
  end

  defp retry(%Job{retries: retries} = state) do
    if retries + 1 >= max_retries() do
      Logger.error(fn -> describe(state) <> " not retrying as too many failures (#{retries + 1})" end)

      {:stop, :too_many_retries, state}
    else
      Logger.debug(fn -> describe(state) <> " will be retried" end)

      send(self(), :execute)

      {:noreply, %Job{state | retries: retries + 1}}
    end
  end

  defp describe(%Job{name: name}), do: "Scheduled job #{inspect(name)}"

  defp max_retries, do: Application.get_env(:commanded_scheduler, :max_retries, 3)
  defp job_timeout, do: Application.get_env(:commanded_scheduler, :job_timeout, :infinity)
end
