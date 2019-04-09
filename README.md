# Commanded scheduler

One-off command scheduler for [Commanded](https://github.com/commanded/commanded) CQRS/ES applications using [Ecto](https://github.com/elixir-ecto/ecto) for persistence.

Commands can be scheduled in one of two ways:

- Using the `Commanded.Scheduler` module as described in the [Example usage](guides/Usage.md#usage) section.
- By [dispatching a scheduled command](guides/Usage.md#dispatch-a-scheduled-command) using your app's router or from within a process manager.

```elixir
Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])
```

---

MIT License

[![Build Status](https://travis-ci.org/commanded/commanded-scheduler.svg?branch=master)](https://travis-ci.org/commanded/commanded-scheduler)

---

## Getting started and usage guides

- [Getting started](guides/Getting%20Started.md)
- [Usage](guides/Usage.md)

### Testing

## Setup
In order to make sure jobs don't clash, you should make sure to clean the job database or table between each test. The approach is the same as described in [Testing Your Application](https://github.com/commanded/commanded/wiki/Testing-your-application)

```elixir
# test/support/storage.exs

defmodule MyApp.Storage do
## This module should contain logic for resetting your read store as well

def reset! do
  :ok = Application.stop(:my_app)
  :ok = Application.stop(:commanded)
  :ok = Application.stop(:eventstore)
  :ok = Application.stop(:commanded_scheduler)

  reset_eventstore()
  ## ADD YOUR READ STORE HERE
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
```


## Running
You can run all the scheduled jobs instantly with `:ok = Commanded.Scheduler.Jobs.run_jobs(run_at_date)`, where `run_at_date` would be the current date and time. Make sure the time is later than the job you want to run. 
 
There's a risk that the job event hasn't fired yet or that the job hasn't been written to ets by the time you call run_jobs so here's four things you can do to get around it:
1. Wait for the `Commanded.Scheduler.ScheduledOnce` event
```elixir
# test/scheduler_test.exs
wait_for_event(Commanded.Scheduler.ScheduledOnce)
```

2. Insert a short wait:
```elixir
 # test/scheduler_test.exs
 ## Wait 10ms before running the jobs
 Process.sleep(10)

 ## Run the job
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

4. Reduce the schedule_interval in the config
```elixir
# config/test.exs
config :commanded_scheduler, schedule_interval: 50
```



