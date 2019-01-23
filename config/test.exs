use Mix.Config

config :logger, :console, level: :warn, format: "[$level] $message\n"

config :ex_unit,
  capture_log: true

config :commanded_scheduler,
  # every 1/2 second
  schedule_interval: 500,
  # app composite router
  router: ExampleDomain.AppRouter

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commanded, event_store_adapter: Commanded.EventStore.Adapters.InMemory

config :commanded, Commanded.EventStore.Adapters.InMemory,
  serializer: Commanded.Serialization.JsonSerializer
