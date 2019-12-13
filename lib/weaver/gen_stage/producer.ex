defmodule Weaver.GenStage.Producer do
  use GenStage

  def start_link(_arg) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add(events) do
    GenServer.cast(__MODULE__, {:add, events})
  end

  # CALLBACKS
  # =========
  @impl GenStage
  def init(_arg) do
    IO.inspect(self(), label: __MODULE__)
    IO.inspect("starting...")
    {:producer, []}
  end

  @impl GenStage
  def handle_cast({:add, events}, state) when is_list(events) do
    {:noreply, events, state}
  end

  def handle_cast({:add, event}, state) do
    {:noreply, [event], state}
  end

  @impl GenStage
  def handle_demand(demand, state) do
    IO.inspect(demand, label: "demand")
    {:noreply, [], state}
  end
end
