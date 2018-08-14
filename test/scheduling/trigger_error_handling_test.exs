defmodule Commanded.Scheduling.TriggerErrorHandlingTest do
  use Commanded.Scheduler.RuntimeCase

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.Jobs
  alias ExampleDomain.ExampleAggregate.{Error, Raise}
  alias ExampleDomain.ExampleRouter

  setup do
    initial_router = Application.get_env(:commanded_scheduler, :router)

    Application.put_env(:commanded_scheduler, :router, ExampleRouter)

    on_exit(fn ->
      Application.put_env(:commanded_scheduler, :router, initial_router)
    end)
  end

  describe "retry on error" do
    setup [:schedule_once_error, :wait_until_job_scheduled, :run_jobs]

    test "should retry three times" do
      assert_receive {:error, "failed"}
      assert_receive {:error, "failed"}
      assert_receive {:error, "failed"}
      refute_receive {:error, "failed"}
    end
  end

  describe "retry on exception" do
    setup [:schedule_once_exception, :wait_until_job_scheduled, :run_jobs]

    test "should retry three times" do
      assert_receive {:exception, "failed"}
      assert_receive {:exception, "failed"}
      assert_receive {:exception, "failed"}
      refute_receive {:exception, "failed"}
    end
  end

  defp schedule_once_error(_context) do
    aggregate_uuid = UUID.uuid4()
    schedule_uuid = UUID.uuid4()
    due_at = DateTime.utc_now()

    command = %Error{
      aggregate_uuid: aggregate_uuid,
      reply_to: :erlang.pid_to_list(self()),
      error: "failed"
    }

    :ok = Commanded.Scheduler.schedule_once(schedule_uuid, command, due_at)

    [due_at: due_at]
  end

  defp schedule_once_exception(_context) do
    aggregate_uuid = UUID.uuid4()
    schedule_uuid = UUID.uuid4()
    due_at = DateTime.utc_now()

    command = %Raise{
      aggregate_uuid: aggregate_uuid,
      reply_to: :erlang.pid_to_list(self()),
      message: "failed"
    }

    :ok = Commanded.Scheduler.schedule_once(schedule_uuid, command, due_at)

    [due_at: due_at]
  end

  defp wait_until_job_scheduled(_context) do
    Wait.until(fn -> assert Jobs.scheduled_jobs() != [] end)
    :ok
  end

  defp run_jobs(context) do
    %{due_at: due_at} = context

    Jobs.run_jobs(due_at)
  end
end
