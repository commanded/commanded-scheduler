use Mix.Config

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
