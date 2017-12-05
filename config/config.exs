use Mix.Config

config :commanded_scheduler,
  ecto_repos: [Commanded.Scheduler.Repo],
  schedule_interval: 60_000,
  max_retries: 3,
  job_timeout: :infinity

import_config "#{Mix.env}.exs"
