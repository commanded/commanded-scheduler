defmodule Commanded.JobsTest do
  use Commanded.Scheduler.RuntimeCase

  alias Commanded.Scheduler.{Jobs,OneOffJob,RecurringJob}

  defmodule Job do
    def execute(name, reply_to) do
      send(reply_to, {:execute, name})
      :ok
    end
  end

  defmodule ErrorJob do
    def execute(name, reply_to) do
      send(reply_to, {:execute, name})
      {:error, :failed}
    end
  end

  describe "schedule once" do
    test "should schedule job" do
      run_at = utc_now()
      Jobs.schedule_once("once", {Job, :execute, [self()]}, run_at)

      assert Jobs.scheduled_jobs() == [
        %OneOffJob{
          name: "once",
          mfa: {Job, :execute, [self()]},
          run_at: run_at,
        }
      ]
      assert Jobs.running_jobs() == []
    end
  end

  describe "schedule recurring" do
    test "should schedule job" do
      Jobs.schedule_recurring("recurring", {Job, :execute, [self()]}, "@daily")

      assert Jobs.scheduled_jobs() == [
        %RecurringJob{
          name: "recurring",
          mfa: {Job, :execute, [self()]},
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

      Jobs.schedule_once("once-due", {Job, :execute, [self()]}, past)
      Jobs.schedule_once("once-not-due", {Job, :execute, [self()]}, future)

      assert Jobs.pending_jobs(now) == [
        %OneOffJob{
          name: "once-due",
          mfa: {Job, :execute, [self()]},
          run_at: past,
        }
      ]
      assert Jobs.running_jobs() == []
    end
  end

  describe "run jobs" do
    test "should execute pending jobs due now" do
      now = utc_now()

      Jobs.schedule_once("once", {Job, :execute, [self()]}, now)
      Jobs.run_jobs(now)

      assert_receive {:execute, "once"}

      :timer.sleep 100

      assert Jobs.pending_jobs(now) == []
      assert Jobs.running_jobs() == []
    end

    test "should retry failed jobs" do
      now = utc_now()

      Jobs.schedule_once("once", {ErrorJob, :execute, [self()]}, now)
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
