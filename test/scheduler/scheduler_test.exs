defmodule Commanded.SchedulerTest do
  use Commanded.Scheduler.RuntimeCase

  alias Commanded.Scheduler

  defmodule Job do
    def execute(name, [reply_to]) do
      send(reply_to, {:executed, name})
      :ok
    end
  end

  describe "schedule once" do
    test "should schedule job" do
      run_at = NaiveDateTime.utc_now()

      Scheduler.schedule_once("once", Job, [self()], run_at)
    end
  end

  describe "schedule recurring" do
    test "should schedule job" do
      Scheduler.schedule_recurring("recurring", Job, [self()], "@daily")
    end
  end
end
