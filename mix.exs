defmodule Returnable.MixProject do
  use Mix.Project

  @source_url "https://github.com/cjbottaro/returnable_ex"

  def project do
    [
      app: :returnable,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Early returns for Elixir",
      package: [
        maintainers: ["Christopher J. Bottaro"],
        licenses: ["MIT"],
        links: %{"GitHub" => @source_url},
      ],

      # Docs
      name: "Returnable",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: [
        main: "Returnable", # The main page in the docs
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.1", only: :dev, runtime: false}
    ]
  end
end
