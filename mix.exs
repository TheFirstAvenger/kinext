defmodule Kinext.MixProject do
  use Mix.Project

  def project do
    [
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "kinext.plt"}
      ],
      app: :kinext,
      version: "0.2.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      compilers: [:my_nifs] ++ Mix.compilers(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Elixir wrapper for Xbox 360 Kinect"
  end

  defp package do
    [
      build_tools: ["make"],
      files: ["lib", "native/nifs", "Makefile", "README.md", "mix.exs"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/TheFirstAvenger/kinext"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_image_info, "~> 0.2.4"},
      {:git_hooks, "~> 0.4.1", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12.2", only: :test},
      {:credo, "~> 1.3.1", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0.2", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    []
  end
end

defmodule Mix.Tasks.Compile.MyNifs do
  def run(_args) do
    {result, errcode} = System.cmd("make", [], stderr_to_stdout: true)
    IO.binwrite(result)

    if errcode == 0 do
      {:ok, []}
    else
      # raise "nif compile make returned #{errcode}"
      {:error,
       [
         %Mix.Task.Compiler.Diagnostic{
           compiler_name: "my_nifs",
           details: result,
           file: "Makefile",
           message: "nif compile make returned #{errcode}",
           position: 1,
           severity: :error
         }
       ]}
    end
  end

  def clean do
    if File.exists?("native/kinext.so") do
      File.rm!("native/kinext.so")
    end
  end
end
