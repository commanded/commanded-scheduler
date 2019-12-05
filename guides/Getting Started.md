# Getting started

## Installation

Commanded scheduler can be installed from hex as follows.

1. Add `commanded_scheduler` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [{:commanded_scheduler, "~> 0.2"}]
   end
   ```

2. Fetch mix dependencies:

   ```console
   mix deps.get
   ```

## Configuration

Commanded scheduler uses its own Ecto repo for persistence.

You must configure the database connection settings for the Ecto repo in the environment config files:

```elixir
# config/config.exs
config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 1
```

You can use an existing database for the Scheduler. It will create a table named `schedules` to store scheduled commands and a `projection_versions`, if not present, used for Commanded's read model projections.

You must also specify which commanded application to use with scheduler.

```elixir
config :commanded_scheduler,
  application: QMES.Application
```

At this time, :commanded_scheduler only supports one application at a time.

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
