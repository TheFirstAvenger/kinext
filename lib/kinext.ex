defmodule Kinext do
  @readme_path Path.join(__DIR__, "../README.md")
  @external_resource @readme_path
  @moduledoc File.read!(@readme_path)
end
