defmodule ChromeLauncher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :chrome_launcher,
      version: "0.0.4",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      name: "Chrome Launcher",
      source_url: "https://github.com/andrewvy/chrome-launcher",
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :erlexec]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:erlexec, "~> 1.7"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Utility library for launching managed chrome processes"
  end

  defp package do
    [
      maintainers: ["andrew@andrewvy.com"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/andrewvy/chrome-launcher"
      }
    ]
  end
end
