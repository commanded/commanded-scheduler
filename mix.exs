defmodule Commanded.Scheduler.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commanded_scheduler,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Commanded.Scheduler.Application, []}
    ]
  end

  defp deps do
    [
      {:commanded, ">= 0.15.0", runtime: false},
    ]
  end
end
