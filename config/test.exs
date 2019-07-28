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

# In-memory event store tests
config :commanded, event_store_adapter: Commanded.EventStore.Adapters.InMemory

config :commanded, Commanded.EventStore.Adapters.InMemory,
  serializer: Commanded.Serialization.JsonSerializer

## EventStore `bytea` tests
# config :commanded, event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :eventstore, EventStore.Storage,
  serializer: JsonSerializer,
  types: EventStore.PostgresTypes,
  username: "postgres",
  password: "postgres",
  database: "eventstore_jsonb_test",
  # database: "eventstore_test",
  hostname: "localhost",
  pool_size: 1

## EventStore `jsonb` tests
# config :commanded, event_store_adapter: Commanded.EventStore.Adapters.EventStore
# config :eventstore, column_data_type: "jsonb"
#
# config :eventstore, EventStore.Storage,
#   serializer: JsonbSerializer,
#   types: EventStore.PostgresTypes,
#   username: "postgres",
#   password: "postgres",
#   database: "eventstore_jsonb_test",
#   hostname: "localhost",
#   pool_size: 1
