defmodule Commanded.Scheduler.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :commanded_scheduler,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package(),
      name: "Commanded scheduler",
      source_url: "https://github.com/commanded/commanded-scheduler"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Commanded.Scheduler.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "event_store.reset": ["event_store.drop", "event_store.create", "event_store.init"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["test --no-start"],
      "test.watch": ["test.watch --no-start"]
    ]
  end

  defp deps do
    [
      {:commanded, "~> 0.17.0", runtime: false},
      {:commanded_ecto_projections, "~> 0.7"},
      {:crontab, "~> 1.1"},
      {:ecto, "~> 2.2"},
      {:ex2ms, "~> 1.5"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.3"},
      {:uuid, "~> 1.1"},

      # Build & test tools
      {:ex_doc, "~> 0.18", only: :dev},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Schedule one-off commands for Commanded CQRS/ES applications.
    """
  end

  defp docs do
    [
      main: "Commanded.Scheduler",
      canonical: "http://hexdocs.pm/commanded_scheduler",
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      extras: [
        "guides/Getting Started.md",
        "guides/Usage.md",
        "CHANGELOG.md"
      ]
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "priv",
        "mix.exs",
        "README*",
        "LICENSE*",
        "CHANGELOG*"
      ],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/commanded/commanded-scheduler",
        "Docs" => "https://hexdocs.pm/commanded_scheduler/"
      }
    ]
  end
end
