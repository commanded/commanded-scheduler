defmodule Commanded.JobsTest do
  use Commanded.Scheduler.RuntimeCase

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

    test "should schedule job", context do
      assert Jobs.scheduled_jobs() == [
        %OneOffJob{
          name: "once",
          module: Job,
          args: [self()],
          run_at: context.run_at,
        }
      ]
      assert Jobs.running_jobs() == []
    end

    test "should execute job after run at time elapses" do
      # wait to allow jobs to execute via internal timer
      :timer.sleep 1_000

      assert_receive {:execute, "once"}

      assert Jobs.scheduled_jobs() == []
      assert Jobs.running_jobs() == []
    end

    defp schedule_once(_context) do
      run_at = utc_now()
      Jobs.schedule_once("once", Job, [self()], run_at)

      [run_at: run_at]
    end
  end

  describe "schedule recurring" do
    test "should schedule job" do
      Jobs.schedule_recurring("recurring", Job, [self()], "@daily")

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
