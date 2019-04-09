# Testing

## Setup

You should clean the job database or table between each test run to ensure jobs don't clash. The approach is the same as described in [Testing Your Application](https://github.com/commanded/commanded/wiki/Testing-your-application)

```elixir
# test/support/storage.exs
defmodule MyApp.Storage do
  def reset! do
    :ok = Application.stop(:my_app)
    :ok = Application.stop(:commanded)
    :ok = Application.stop(:eventstore)
    :ok = Application.stop(:commanded_scheduler)

    reset_eventstore()
    reset_readstore()
    reset_scheduler()

    {:ok, _} = Application.ensure_all_started(:my_app)
  end

  defp reset_scheduler do
    scheduler_config = Application.get_env(:commanded_scheduler, Commanded.Scheduler.Repo)

    {:ok, conn} = Postgrex.start_link(scheduler_config)

    Postgrex.query!(conn, truncate_scheduler_tables(), [])
  end

  defp truncate_scheduler_tables do
    """
    TRUNCATE TABLE
      projection_versions,
      schedules
    RESTART IDENTITY;
    """
  end
end
```

## Running

You can run all the scheduled jobs instantly with `:ok = Commanded.Scheduler.Jobs.run_jobs(run_at_date)`, where `run_at_date` would be the current date and time. Make sure the time is later than the job you want to run.

There's a risk that the job event hasn't fired yet or that the job hasn't been written to ETS by the time you call `run_jobs/1` so here are four things you can do to get around it:

  1. Wait for the `Commanded.Scheduler.ScheduledOnce` event:

      ```elixir
      # test/scheduler_test.exs
      import Commanded.Assertions.EventAssertions

      wait_for_event(Commanded.Scheduler.ScheduledOnce)
      ```

  2. Insert a short wait:

      ```elixir
       # test/scheduler_test.exs
       Process.sleep(10)

       :ok = Commanded.Scheduler.Jobs.run_jobs(Timex.now() |> Timex.shift(days: 1))
      ```

  3. Wait for a job to be added to the job queue:

      ```elixir
      # test/scheduler_test.exs
      alias Commanded.Helpers.Wait
      alias Commanded.Scheduler.Jobs

      Wait.until(fn ->
        refute Jobs.scheduled_jobs() == []
      end)
      ```

  4. Reduce the schedule_interval in the config:

      ```elixir
      # config/test.exs
      config :commanded_scheduler, schedule_interval: 50
      ```
