defmodule Commanded.Scheduler.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commanded_scheduler,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Commanded.Scheduler.Application, []}
    ]
  end

  defp aliases do
    [
      "event_store.reset": ["event_store.drop", "event_store.create", "event_store.init"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"],
    ]
  end

  defp deps do
    [
      {:commanded, ">= 0.15.0", runtime: false},
      {:commanded_ecto_projections, "~> 0.6"},
      {:ecto, "~> 2.2"},
      {:uuid, "~> 1.1"},
    ]
  end
end
