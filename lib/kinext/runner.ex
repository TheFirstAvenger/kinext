defmodule Kinext.Runner do
  @moduledoc """
  Example usage of the video and LED functionality in Kinext. Can be run via
  `mix kinext.go_picture` and `mix kinext.go_led`
  """
  def go_picture do
    {:ok, context} = Kinext.Context.init()
    {:ok, device} = Kinext.Context.open_device(context, 1)
    {:ok, video} = Kinext.Video.new(context, device)
    :timer.sleep(1000)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 1)
    :timer.sleep(500)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 2)
    :timer.sleep(500)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 3)
    :timer.sleep(500)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 4)
    :timer.sleep(500)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 5)
    :timer.sleep(500)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 6)
    :timer.sleep(500)
    {:ok, frame} = Kinext.Video.get_frame(video)
    write(frame, 7)
    :timer.sleep(500)

    Kinext.Context.shutdown(context)
    IO.puts("shut down")
  end

  def write(frame, count) do
    file = File.open!("tt#{count}.png", [:write])
    :ok = IO.binwrite(file, frame)
    :ok = File.close(file)
  end

  def go_led do
    {:ok, context} = Kinext.Context.init()
    {:ok, device} = Kinext.Context.open_device(context, 1)
    :ok = Kinext.Device.set_led(device, :green)
    :timer.sleep(1000)
    :ok = Kinext.Device.set_led(device, :red)
    :timer.sleep(1000)
    # :ok = Kinext.Device.set_led(device, :yellow)
    # :timer.sleep(1000)
    :ok = Kinext.Device.set_led(device, :blink_red_orange)
    :timer.sleep(1000)
    Kinext.Context.shutdown(context)
    IO.puts("shut down")
    :timer.sleep(1000)
  end
end
