use Mix.Config

config :commanded_scheduler,
  ecto_repos: [Commanded.Scheduler.Repo],
  schedule_interval: 60_000

import_config "#{Mix.env}.exs"
