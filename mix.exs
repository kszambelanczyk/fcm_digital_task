defmodule FcmDigitalTask.MixProject do
  use Mix.Project

  def project do
    [
      app: :fcm_digital_task,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 1.4.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
