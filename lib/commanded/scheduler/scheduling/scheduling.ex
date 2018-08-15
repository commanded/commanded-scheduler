defmodule Commanded.Scheduler.Scheduling do
  @moduledoc false

  use Commanded.Event.Handler, name: "Commanded.Scheduler.Scheduling"

  require Logger

  alias Commanded.Event.FailureContext

  alias Commanded.Scheduler.{
    Dispatcher,
    Jobs,
    Repo,
    ScheduleCancelled,
    ScheduledOnce,
    ScheduleTriggered,
    TriggerSchedule
  }

  alias Commanded.Scheduler.Projection.Schedule

  @doc """
  Reschedule all existing schedules on start.
  """
  def init do
    for schedule <- Repo.all(Schedule) do
      %Schedule{
        schedule_uuid: schedule_uuid,
        name: name,
        due_at: due_at
      } = schedule

      schedule_once(schedule_uuid, name, due_at)
    end

    :ok
  end

  # Schedule the command to be triggered at the given due date/time.
  def handle(%ScheduledOnce{} = event, _metadata) do
    %ScheduledOnce{
      schedule_uuid: schedule_uuid,
      name: name,
      command: command,
      due_at: due_at
    } = event

    Logger.debug(fn -> "Scheduling command #{inspect(command)} once at: #{inspect(due_at)}" end)

    schedule_once(schedule_uuid, name, due_at)
  end

  # Execute the command using the configured router when triggered at its
  # scheduled date/time.
  def handle(%ScheduleTriggered{command: command}, metadata) do
    %{
      correlation_id: correlation_id,
      event_id: event_id
    } = metadata

    Logger.debug(fn -> "Attempting to dispatch scheduled command: #{inspect(command)}" end)

    router().dispatch(command, causation_id: event_id, correlation_id: correlation_id)
  end

  # Execute the command using the configured router when triggered at its
  # scheduled date/time.
  def handle(%ScheduleCancelled{schedule_uuid: schedule_uuid, name: name}, _metadata) do
    Logger.debug(fn -> "Cancelling scheduled command: #{inspect(schedule_uuid)}" end)

    case Jobs.cancel({schedule_uuid, name}) do
      :ok ->
        :ok

      {:error, :not_scheduled} ->
        Logger.warn(fn ->
          "Failed to cancel scheduled command, not scheduled: #{inspect(schedule_uuid)}"
        end)

        :ok
    end
  end

  @doc """
  Retry on error for the configured number of maximum retries.

  You may override the default number of three retries in config:

      # config/config.exs
      config :commanded_scheduler, max_retries: 3,

  """
  def error({:error, error}, event, %FailureContext{} = failure_context) do
    %FailureContext{context: context, metadata: metadata} = failure_context

    event_id = Map.get(metadata, :event_id)
    event_number = Map.get(metadata, :event_number)
    context = Map.update(context, :failures, 1, fn failures -> failures + 1 end)
    max_retries = max_retries()

    case Map.get(context, :failures) do
      too_many when too_many >= max_retries ->
        Logger.error(fn ->
          "Skipping event " <>
            inspect(event_id) <>
            " (##{inspect(event_number)}) due to too many failures: " <> inspect(event)
        end)

        # Skip problematic event after third failure
        :skip

      _ ->
        Logger.warn(fn ->
          "Failed to handle event " <>
            inspect(event_id) <> " (##{inspect(event_number)}) due to: " <> inspect(error)
        end)

        # Retry event, failure count is included in context map
        {:retry, context}
    end
  end

  defp schedule_once(schedule_uuid, name, due_at) do
    trigger_schedule = %TriggerSchedule{schedule_uuid: schedule_uuid, name: name}

    case Jobs.schedule_once({schedule_uuid, name}, Dispatcher, trigger_schedule, due_at) do
      :ok ->
        :ok

      {:error, :already_scheduled} ->
        Logger.warn(fn ->
          "Failed to schedule command, already scheduled: #{inspect(schedule_uuid)}"
        end)

        :ok
    end
  end

  defp router do
    Application.get_env(:commanded_scheduler, :router) ||
      raise "Commanded scheduler expects `:router` to be defined in config"
  end

  defp max_retries, do: Application.get_env(:commanded_scheduler, :max_retries, 3)
end
