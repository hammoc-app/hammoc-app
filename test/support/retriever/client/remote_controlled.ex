defmodule Hammoc.Retriever.Client.RemoteControlled do
  @moduledoc "Sends replies based on `send_reply/1` calls to this process."

  use GenServer

  alias Hammoc.Retriever.Client

  @behaviour Client

  @impl Client
  def init() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    GenServer.call(__MODULE__, :init)
  end

  @impl Client
  def next_batch(retrieval_job) do
    GenServer.call(__MODULE__, {:next_batch, retrieval_job})
  end

  @doc "Returns the last received `GenServer.call/2` and triggers the given reply."
  def send_reply(reply) do
    GenServer.call(__MODULE__, {:send_reply, reply})
  end

  @impl GenServer
  def init(_args) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:send_reply, reply}, _from, state) do
    GenServer.reply(state.from, reply)

    {:reply, {:ok, state.msg}, nil}
  end

  def handle_call(msg, from, _state) do
    {:noreply, %{msg: msg, from: from}}
  end
end
