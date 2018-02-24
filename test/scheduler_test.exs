defmodule Commanded.SchedulerTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler
  alias Commanded.Scheduler.{Batch, Jobs}
  alias Timex.Duration
  alias ExampleDomain.ExampleRouter
  alias ExampleDomain.ExampleAggregate.{Execute, Executed}

  setup do
    original_router = Application.get_env(:commanded_scheduler, :router)

    Application.put_env(:commanded_scheduler, :router, ExampleRouter)

    on_exit(fn ->
      Application.put_env(:commanded_scheduler, :router, original_router)
    end)
  end

  describe "schedule once" do
    test "should schedule job" do
      aggregate_uuid = UUID.uuid4()
      command = %Execute{aggregate_uuid: aggregate_uuid, data: "once"}
      run_at = NaiveDateTime.utc_now()

      Scheduler.schedule_once("once", command, run_at)

      Scheduler.Jobs.run_jobs(run_at)

      assert_receive_event(Executed, fn executed ->
        assert executed.data == "once"
      end)
    end
  end

  describe "schedule recurring" do
    @tag :pending
    test "should schedule job" do
      aggregate_uuid = UUID.uuid4()
      command = %Execute{aggregate_uuid: aggregate_uuid, data: "once"}

      Scheduler.schedule_recurring("recurring", command, "@daily")

      now = NaiveDateTime.utc_now()
      tomorrow = Timex.add(now, Duration.from_days(1))
      Scheduler.Jobs.run_jobs(tomorrow)

      assert_receive_event(Executed, fn executed ->
        assert executed.data == "recurring"
      end)
    end
  end

  describe "schedule batch" do
    test "should schedule all jobs" do
      aggregate_uuid = UUID.uuid4()
      command1 = %Execute{aggregate_uuid: aggregate_uuid, data: "once1"}
      command2 = %Execute{aggregate_uuid: aggregate_uuid, data: "once2"}
      run_at = NaiveDateTime.utc_now()

      batch =
        "batch"
        |> Batch.new()
        |> Batch.schedule_once(command1, run_at)
        |> Batch.schedule_once(command2, run_at)

      Scheduler.schedule_batch(batch)

      Scheduler.Jobs.run_jobs(run_at)

      assert_receive_event(Executed, fn executed -> executed.data == "once1" end, fn executed ->
        assert executed.data == "once1"
      end)

      assert_receive_event(Executed, fn executed -> executed.data == "once2" end, fn executed ->
        assert executed.data == "once2"
      end)
    end
  end

  describe "cancel schedule" do
    setup [:schedule_once, :cancel_schedule]

    test "should remove scheduled job" do
      Wait.until(fn -> assert Jobs.scheduled_jobs() == [] end)
    end

    test "should error when job already cancelled" do
      assert {:error, :no_schedule} = Scheduler.cancel_schedule("once")
    end

    test "should error when job does not exist" do
      assert {:error, :no_schedule} = Scheduler.cancel_schedule("doesnotexist")
    end

    test "should not execute job", %{aggregate_uuid: aggregate_uuid, run_at: run_at} do
      Scheduler.Jobs.run_jobs(run_at)

      assert Commanded.EventStore.stream_forward(aggregate_uuid) == {:error, :stream_not_found}
    end

    defp schedule_once(_context) do
      aggregate_uuid = UUID.uuid4()
      command = %Execute{aggregate_uuid: aggregate_uuid, data: "once"}
      run_at = NaiveDateTime.utc_now()

      Scheduler.schedule_once("once", command, run_at)

      Wait.until(fn -> refute Jobs.scheduled_jobs() == [] end)

      [
        aggregate_uuid: aggregate_uuid,
        run_at: run_at
      ]
    end

    defp cancel_schedule(_context) do
      Scheduler.cancel_schedule("once")
    end
  end

  describe "configure schedule prefix" do
    setup do
      Application.put_env(:commanded_scheduler, :schedule_prefix, "prefix-")

      on_exit(fn ->
        Application.delete_env(:commanded_scheduler, :schedule_prefix)
      end)
    end

    test "should prefix stream" do
      aggregate_uuid = UUID.uuid4()
      command = %Execute{aggregate_uuid: aggregate_uuid, data: "once"}
      run_at = NaiveDateTime.utc_now()

      Scheduler.schedule_once("once", command, run_at)

      assert Commanded.EventStore.stream_forward("once") == {:error, :stream_not_found}
      refute Commanded.EventStore.stream_forward("prefix-once") |> Enum.to_list() == []
    end
  end
end
