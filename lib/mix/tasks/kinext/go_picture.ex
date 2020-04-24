defmodule Mix.Tasks.Kinext.GoPicture do
  use Mix.Task

  @shortdoc "Calls Kinext.Runner.go_picture()"
  def run(_) do
    Kinext.Runner.go_picture()
  end
end
