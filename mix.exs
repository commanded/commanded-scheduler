defmodule Commanded.Scheduler.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commanded_scheduler,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do:     ["lib"]

  defp aliases do
    [
      "event_store.reset":  ["event_store.drop", "event_store.create", "event_store.init"],
      "ecto.setup":         ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset":         ["ecto.drop", "ecto.setup"],
      "test":               ["test --no-start"],
    ]
  end

  defp deps do
    [
      {:commanded, ">= 0.15.0", runtime: false},
      {:commanded_ecto_projections, "~> 0.6"},
      {:ecto, "~> 2.2"},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:postgrex, ">= 0.0.0"},
      {:uuid, "~> 1.1"},
    ]
  end
end
