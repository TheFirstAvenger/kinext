defmodule Kinext.Video do
  @moduledoc """
  Interface for, and struct representing, a video "context" for a kinext device.

  To access the video with kinext, you must first create a new video context via the `new/2` function.
  To retrieve each frame of the video, you then request a frame via the `get_frame/1` function.

  The underlying OpenKinect video paradigm is complex (raw RGB, pointers, and callbacks), and this
  abstraction eliminates that complexity.
  """
  defstruct [:context, :device, :listener_pid]

  alias Kinext.Context
  alias Kinext.Device
  alias Kinext.Native
  alias Kinext.Video
  alias Kinext.Video.Listener

  require Logger

  @type t :: %__MODULE__{
          context: Context.t(),
          device: Device.t(),
          listener_pid: pid()
        }

  def new(%Context{} = context, %Device{ref: ref} = device) do
    {:ok, listener_pid} = Listener.start_link()

    case Native.kinext_start_video(ref, listener_pid) do
      0 ->
        {:ok,
         %Video{
           context: context,
           device: device,
           listener_pid: listener_pid
         }}

      error ->
        {:error, error}
    end
  end

  def get_frame(%Video{context: %Context{ref: ref}, listener_pid: listener_pid} = video) do
    Kinext.Native.freenect_process_events(ref)

    case Listener.get_last_frame(listener_pid) do
      {:error, :no_frame} ->
        Logger.warn("No frame returned from listener, retrying")
        :timer.sleep(50)
        get_frame(video)

      {:ok, frame} ->
        {:ok, frame}
    end
  end
end
