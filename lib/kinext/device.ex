defmodule Kinext.Device do
  defstruct [:ref]

  @type t :: %__MODULE__{
          ref: reference()
        }

  alias Kinext.Device
  alias Kinext.Native

  @led_map %{
    off: 0,
    green: 1,
    red: 2,
    # yellow in freenect
    orange: 3,
    # blink_yellow: 4, #Same as 5
    blink_green: 5,
    # blink red yellow in freenect
    blink_red_orange: 6
  }

  @led_colors Map.keys(@led_map)

  def set_led(%Device{ref: ref}, color) when color in @led_colors do
    IO.inspect(@led_colors)

    case Native.freenect_set_led(ref, Map.get(@led_map, color)) do
      0 -> :ok
      error -> {:error, error}
    end
  end

  def get_tilt_degs(%Device{ref: ref}) do
    case Native.freenect_get_tilt_degs(ref) do
      f when is_float(f) -> {:ok, f}
      error -> {:error, error}
    end
  end

  def set_tilt_degs(%Device{ref: ref}, tilt_degs) when tilt_degs in 31..-31 do
    case Native.freenect_set_tilt_degs(ref, tilt_degs / 1) do
      0 -> :ok
      error -> {:error, error}
    end
  end
end
