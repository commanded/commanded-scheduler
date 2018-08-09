# Commanded scheduler

One-off and recurring command scheduler for [Commanded](https://github.com/commanded/commanded) CQRS/ES applications using [Ecto](https://github.com/elixir-ecto/ecto) for persistence.

Commands can be scheduled in one of two ways:

- Using the `Commanded.Scheduler` module as described in the [Example usage](#example-usage) section.
- By [dispatching a scheduled command](#dispatch-scheduled-command) using your app's router or from within a process manager.

This library is under active development.

---

MIT License

[![Build Status](https://travis-ci.org/commanded/commanded-scheduler.svg?branch=master)](https://travis-ci.org/commanded/commanded-scheduler)

---

## Configuration

Commanded scheduler uses its own Ecto repo for persistence.

You must configure the database connection settings for the Ecto repo in the environment config files:

```elixir
# config/dev.exs
config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 1
```

You can use an existing database for the Scheduler. It will create a table named `schedules` to store scheduled commands and a `projection_versions`, if not present, used for Commanded's read model projections.

### Create Commanded scheduler database

Once configured, you can create and migrate the scheduler database using Ecto's mix tasks.

Specify the Commanded scheduler's Ecto repo for the mix tasks using the `--repo` or `-r` command line option:

```console
mix ecto.create --repo Commanded.Scheduler.Repo
mix ecto.migrate --repo Commanded.Scheduler.Repo
```

Alternatively, you can include `Commanded.Scheduler.Repo` in the `ecto_repos` config for your own application:

```elixir
# config/config.exs
config :my_app,
  ecto_repos: [
    MyApp.Repo,
    Commanded.Scheduler.Repo
  ]

config :my_app, Commanded.Scheduler.Repo,
  migration_source: "scheduler_schema_migrations"
```

You _must set_ the `migration_source` for the scheduler repo to a different table name from Ecto's default (`schema_migrations`) as shown above. This ensures that migrations for your own application's Ecto repo do not interfere with the Scheduler migrations when running `mix ecto.migrate`.

Then using Ecto's mix tasks will include the Commanded scheduler repository at the same time as your own app's:

```console
mix do ecto.create, ecto.migrate
```

## Example usage

### Schedule a one-off command

Schedule a uniquely identified one-off job using the given command to dispatch at the specified date/time.

#### Example

```elixir
Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])
```

Name the scheduled job:

```elixir
Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, due_at, name: "timeout")
```

### Schedule a recurring command

Schedule a uniquely identified recurring job using the given command to dispatch repeatedly on the given schedule.

Schedule supports the cron format where the minute, hour, day of month, month, and day of week (0 - 6, Sunday to Saturday) are specified. An example crontab schedule is "45 23 * * 6". It would trigger at 23:45 (11:45 PM) every Saturday.

For more details please refer to https://en.wikipedia.org/wiki/Cron.

#### Example

Schedule a job to run every 15 minutes:

```elixir
Commanded.Scheduler.schedule_recurring(reservation_id, %TimeoutReservation{..}, "*/15 * * * *")
```

Name the recurring job that runs every day at midnight:

```elixir
Commanded.Scheduler.schedule_recurring(reservation_id, %TimeoutReservation{..}, "@daily", name: "timeout")
```

## Schedule multiple one-off or recurring commands in a single batch

This guarantees that all, or none, of the commands are scheduled.

#### Example

```elixir
alias Commanded.Scheduler
alias Commanded.Scheduler.Batch

batch =
  reservation_id
  |> Batch.new()
  |> Batch.schedule_once(%TimeoutReservation{..}, timeout_due_at, name: "timeout")
  |> Batch.schedule_once(%ReleaseSeat{..}, release_due_at, name: "release")

Scheduler.schedule_batch(batch)  
```

## Dispatch scheduled command

You can dispatch a scheduled command by defining a composite Commanded router for your application and including the `Commanded.Scheduler.Router`:

```elixir
defmodule AppRouter do
  @moduledoc false

  use Commanded.Commands.CompositeRouter

  router ExampleDomain.TicketRouter
  router Commanded.Scheduler.Router
end
```

Then you can dispatch a `Commanded.Scheduler.ScheduleOnce`, `Commanded.Scheduler.ScheduleRecurring`, or `Commanded.Scheduler.ScheduleBatch` command, including the command to be executed later:

```elixir
timeout_reservation = %TimeoutReservation{
  ticket_uuid: ticket_uuid
}

schedule_once = %ScheduleOnce{
  schedule_uuid: ticket_uuid,
  command: timeout_reservation,
  due_at: expires_at,
}

AppRouter.dispatch(schedule_once)
```

This approach allows you to dispatch a command from within a process manager:

```elixir
defmodule TicketProcessManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "TicketProcessManager",
    router: AppRouter

  defstruct [:ticket_uuid]

  def interested?(%TicketReserved{ticket_uuid: ticket_uuid}),
    do: {:start, ticket_uuid}

  def handle(
    %TicketProcessManager{},
    %TicketReserved{ticket_uuid: ticket_uuid, expires_at: expires_at})
  do
    %ScheduleOnce{
      schedule_uuid: ticket_uuid,
      command: %TimeoutReservation{ticket_uuid: ticket_uuid},
      due_at: expires_at
    }
  end
end
```

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



