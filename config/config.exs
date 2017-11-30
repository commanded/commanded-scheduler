use Mix.Config

config :commanded_scheduler,
  ecto_repos: [Commanded.Scheduler.Repo]

import_config "#{Mix.env}.exs"
