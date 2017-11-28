defmodule Commanded.JobsTest do
  use Commanded.Scheduler.RuntimeCase

  alias Commanded.Scheduler.{Jobs,OneOffJob,RecurringJob}

  defmodule Job do
    def execute(name, reply_to) do
      send(reply_to, {:execute, name})
      :ok
    end
  end

  describe "schedule once" do
    test "should schedule job" do
      run_at = utc_now()
      Jobs.schedule_once("once", {Job, :execute, [self()]}, run_at)

      jobs = Jobs.scheduled_jobs()

      assert jobs == [
        %OneOffJob{
          name: "once",
          mfa: {Job, :execute, [self()]},
          run_at: run_at,
        }
      ]
    end
  end

  describe "schedule recurring" do
    test "should schedule job" do
      Jobs.schedule_recurring("recurring", {Job, :execute, [self()]}, "@daily")

      jobs = Jobs.scheduled_jobs()

      assert jobs == [
        %RecurringJob{
          name: "recurring",
          mfa: {Job, :execute, [self()]},
          schedule: "@daily",
        }
      ]
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
    end
  end

  describe "run jobs" do
    @tag :wip
    test "should execute pending jobs due now" do
      now = utc_now()
      past = NaiveDateTime.add(now, -60, :second)
      future = NaiveDateTime.add(now, 60, :second)

      Jobs.schedule_once("once-due", {Job, :execute, [self()]}, past)
      Jobs.schedule_once("once-not-due", {Job, :execute, [self()]}, future)

      Jobs.run_jobs(now)

      assert_receive {:execute, "once-due"}
      assert Jobs.pending_jobs(now) == []
    end
  end

  defp utc_now, do: NaiveDateTime.utc_now()
end
