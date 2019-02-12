defmodule ConfigZ.MixProject do
  use Mix.Project

  def project do
    [
      app: :config_z,
      version: "0.3.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      name: "ConfigZ",
      package: package(),
      source_url: "https://github.com/cctiger36/config_z",
      homepage_url: "https://github.com/cctiger36/config_z",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      dialyzer: [
        flags: [:no_undefined_callbacks],
        ignore_warnings: "dialyzer.ignore-warnings",
        remove_defaults: [:unknown]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.travis": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ConfigZ, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:file_system, "~> 0.2"},
      {:inner_cotton, "~> 0.2", only: [:dev, :test]},
      {:mock, "~> 0.3", only: :test}
    ]
  end

  defp package do
    [
      files: ["LICENSE", "README.md", "mix.exs", "lib"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cctiger36/config_z"},
      maintainers: ["cctiger36 <cctiger36@gmail.com>"],
      name: "config_z"
    ]
  end

  defp description do
    "Runtime configuration for Elixir applications."
  end
end
