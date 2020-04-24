defmodule Kinext.Native do
  @moduledoc """
  Provides access to C NIFs.

  This module is used by the higher level modules such as `Kinext.Context`, `Kinext.Device`, and `Kinext.Video`.
  """
  @on_load :load_nifs

  def load_nifs do
    path =
      __DIR__
      |> Path.join("../../native/kinext")
      |> String.to_charlist()

    :erlang.load_nif(path, 0)
  end

  @spec freenect_init :: reference() | integer()
  def freenect_init do
    :erlang.nif_error("NIF freenect_init not implemented")
  end

  @spec freenect_shutdown(reference()) :: integer()
  def freenect_shutdown(ref) when is_reference(ref) do
    :erlang.nif_error("NIF freenect_init not implemented")
  end

  @spec freenect_num_devices(reference()) :: integer()
  def freenect_num_devices(ref) when is_reference(ref) do
    :erlang.nif_error("NIF freenect_num_devices not implemented")
  end

  @spec freenect_open_device(reference(), integer()) :: reference() | integer()
  def freenect_open_device(ref, index) when is_reference(ref) and is_integer(index) do
    :erlang.nif_error("NIF freenect_open_device not implemented")
  end

  @spec freenect_set_led(reference(), integer()) :: integer()
  def freenect_set_led(ref, index) when is_reference(ref) and is_integer(index) do
    :erlang.nif_error("NIF freenect_set_led not implemented")
  end

  @spec freenect_get_tilt_degs(reference()) :: float() | integer()
  def freenect_get_tilt_degs(ref) when is_reference(ref) do
    :erlang.nif_error("NIF freenect_get_tilt_degs not implemented")
  end

  @spec freenect_set_tilt_degs(reference(), float()) :: integer()
  def freenect_set_tilt_degs(ref, index) when is_reference(ref) and is_float(index) do
    :erlang.nif_error("NIF freenect_set_tilt_degs not implemented")
  end

  @spec kinext_start_video(reference(), pid()) :: integer()
  def kinext_start_video(ref, pid) when is_reference(ref) and is_pid(pid) do
    :erlang.nif_error("NIF kinext_start_video not implemented")
  end

  @spec freenect_process_events(reference()) :: integer()
  def freenect_process_events(ref) when is_reference(ref) do
    :erlang.nif_error("NIF freenect_process_events not implemented")
  end
end
