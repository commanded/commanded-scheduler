use Mix.Config

config :logger, :console, level: :warn, format: "[$level] $message\n"

config :ex_unit,
  capture_log: true

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.InMemory
