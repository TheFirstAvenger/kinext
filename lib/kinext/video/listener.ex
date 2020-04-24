defmodule Kinext.Video.Listener do
  @moduledoc false

  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok)
  end

  def get_last_frame(server) do
    GenServer.call(server, :get_last_frame)
  end

  def init(:ok) do
    {:ok, %{frames: []}}
  end

  def handle_call(:get_last_frame, _from, %{frames: []} = state),
    do: {:reply, {:error, :no_frame}, state}

  def handle_call(:get_last_frame, _from, %{frames: [frame]} = state),
    do: {:reply, {:ok, frame}, %{state | frames: []}}

  def handle_call(:get_last_frame, _from, %{frames: [frame | _]} = state) do
    Logger.warn("Multiple frames found")
    {:reply, {:ok, frame}, %{state | frames: []}}
  end

  def handle_info(bin, %{frames: frames} = state) when is_binary(bin) do
    {:noreply, %{state | frames: [bin | frames]}}
  end
end
