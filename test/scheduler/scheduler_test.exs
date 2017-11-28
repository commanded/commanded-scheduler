defmodule Commanded.SchedulerTest do
  use Commanded.Scheduler.RuntimeCase

  alias Commanded.Scheduler
  alias Commanded.Scheduler.{Jobs,OneOffJob,RecurringJob}

  defmodule Job do
    def execute(reply_to) do
      send(reply_to, :executed)
      :ok
    end
  end

  describe "schedule once" do
    test "should schedule job" do
      run_at = utc_now()
      Scheduler.schedule_once("once", {Job, :execute, [self()]}, run_at)

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
      Scheduler.schedule_recurring("recurring", {Job, :execute, [self()]}, "@daily")

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

  defp utc_now, do: NaiveDateTime.utc_now()
end
