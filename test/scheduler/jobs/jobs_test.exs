defmodule Commanded.JobsTest do
  use Commanded.Scheduler.RuntimeCase

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.{Jobs,OneOffJob,RecurringJob}

  defmodule Job do
    @behaviour Commanded.Scheduler.Job

    def execute(name, [reply_to]) do
      send(reply_to, {:execute, name})
      :ok
    end
  end

  defmodule ErrorJob do
    @behaviour Commanded.Scheduler.Job

    def execute(name, [reply_to]) do
      send(reply_to, {:execute, name})
      {:error, :failed}
    end
  end

  describe "schedule once" do
    setup [:schedule_once]

    test "should schedule job", %{run_at: run_at} do
      assert Jobs.scheduled_jobs() == [
        %OneOffJob{
          name: "once",
          module: Job,
          args: [self()],
          run_at: run_at,
        }
      ]
      assert Jobs.running_jobs() == []
    end

    test "should reject already scheduled job" do
      assert {:error, :already_scheduled} = Jobs.schedule_once("once", Job, [self()], utc_now())
      assert Jobs.scheduled_jobs() |> length() == 1
    end

    test "should execute job after run at time elapses", %{run_at: run_at} do
      # execute pending jobs at the given "now" date/time
      Jobs.run_jobs(run_at)

      assert_receive {:execute, "once"}

      Wait.until(fn ->
        assert Jobs.scheduled_jobs() == []
        assert Jobs.running_jobs() == []
      end)
    end

    defp schedule_once(_context) do
      run_at = utc_now()
      Jobs.schedule_once("once", Job, [self()], run_at)

      [run_at: run_at]
    end
  end

  describe "schedule recurring" do
    setup [:schedule_recurring]

    test "should schedule job" do
      assert Jobs.scheduled_jobs() == [
        %RecurringJob{
          name: "recurring",
          module: Job,
          args: [self()],
          schedule: "@daily",
        }
      ]
      assert Jobs.running_jobs() == []
    end

    test "should reject already scheduled job" do
      assert {:error, :already_scheduled} = Jobs.schedule_recurring("recurring", Job, [self()], "@daily")
      assert Jobs.scheduled_jobs() |> length() == 1
    end

    defp schedule_recurring(_context) do
      Jobs.schedule_recurring("recurring", Job, [self()], "@daily")
    end
  end

  describe "pending jobs" do
    test "should get pending jobs due now" do
      now = utc_now()
      past = NaiveDateTime.add(now, -60, :second)
      future = NaiveDateTime.add(now, 60, :second)

      Jobs.schedule_once("once-due", Job, [self()], past)
      Jobs.schedule_once("once-not-due", Job, [self()], future)

      assert Jobs.pending_jobs(now) == [
        %OneOffJob{
          name: "once-due",
          module: Job,
          args: [self()],
          run_at: past,
        }
      ]
      assert Jobs.running_jobs() == []
    end
  end

  describe "run jobs" do
    test "should execute pending jobs due now" do
      now = utc_now()

      Jobs.schedule_once("once", Job, [self()], now)
      Jobs.run_jobs(now)

      assert_receive {:execute, "once"}

      :timer.sleep 100

      assert Jobs.pending_jobs(now) == []
      assert Jobs.running_jobs() == []
    end

    test "should retry failed jobs" do
      now = utc_now()

      Jobs.schedule_once("once", ErrorJob, [self()], now)
      Jobs.run_jobs(now)

      assert_receive {:execute, "once"}
      assert_receive {:execute, "once"}
      assert_receive {:execute, "once"}

      refute_receive {:execute, "once"}

      assert Jobs.pending_jobs(now) == []
      assert Jobs.running_jobs() == []
    end
  end

  defp utc_now, do: NaiveDateTime.utc_now()
end
