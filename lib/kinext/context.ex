defmodule Kinext.Context do
  @moduledoc """
  Interface for, and structure representing, an OpenKinect context.

  OpenKinect contexts are the top level entity in OpenKinect, from which you can access the list of devices.
  """
  defstruct [:ref]

  @type t :: %__MODULE__{
          ref: reference()
        }

  alias Kinext.Context
  alias Kinext.Device

  def init do
    case Kinext.Native.freenect_init() do
      reference when is_reference(reference) -> {:ok, %__MODULE__{ref: reference}}
      other -> {:error, other}
    end
  end

  def shutdown(%Context{ref: ref}) do
    case Kinext.Native.freenect_shutdown(ref) do
      0 -> :ok
      _ -> :error
    end
  end

  def num_devices(%Context{ref: ref}) do
    case Kinext.Native.freenect_num_devices(ref) do
      x when x >= 0 -> {:ok, x}
      x -> {:error, x}
    end
  end

  def open_device(%Context{ref: ref}, index) do
    case Kinext.Native.freenect_open_device(ref, index) do
      reference when is_reference(reference) -> {:ok, %Device{ref: reference}}
      x -> {:error, x}
    end
  end

  def process_events(%Context{ref: ref}) do
    case Kinext.Native.freenect_process_events(ref) do
      0 -> :ok
      error -> {:error, error}
    end
  end
end
