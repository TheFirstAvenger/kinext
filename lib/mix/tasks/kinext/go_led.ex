defmodule Mix.Tasks.Kinext.GoLed do
  use Mix.Task

  @shortdoc "Calls Kinext.Runner.go_led()"
  def run(_) do
    Kinext.Runner.go_led()
  end
end
