defmodule Weaver.GenStage.Prosumer do
  use GenStage

  @max_demand 1

  alias __MODULE__.State

  defmodule State do
    defstruct [:name, :status, :retrieval, producers: %{}, demand: 0, queue: []]
  end

  def start_link(opts = {name, _subscriptions}) do
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  @impl GenStage
  def init({name, subscriptions}) do
    IO.inspect(self(), label: name)

    Enum.each(subscriptions, fn subscription ->
      opts =
        case subscription do
          {name, opts} -> [{:to, name} | opts]
          name -> [to: name]
        end
        |> Keyword.put_new(:max_demand, @max_demand)

      GenStage.async_subscribe(self(), opts)
    end)

    {:producer, %State{name: name, status: :waiting_for_consumers}}
  end

  @impl GenStage
  def handle_subscribe(:producer, opts, from, state) do
    pending = opts[:max_demand] || @max_demand

    state = put_in(state.producers[from], pending)
    if state.status == :waiting_for_producers, do: GenStage.ask(from, pending)

    # Returns manual as we want control over the demand
    {:manual, state}
  end

  def handle_subscribe(:consumer, _opts, _from, state) do
    {:automatic, state}
  end

  @impl GenStage
  def handle_cancel(_, from, state) do
    # Remove the producers from the map on unsubscribe
    producers = Map.delete(state.producers, from)

    {:noreply, [], %{state | producers: producers}}
  end

  @impl GenStage
  def handle_events(events, from, state) when is_list(events) do
    IO.inspect(length(events), label: "QUEUE #{state.name}")

    state =
      update_in(state.producers[from], &(&1 + length(events)))
      |> Map.update!(:queue, &(&1 ++ events))

    noreply([], state)
  end

  @impl GenStage
  def handle_demand(demand, state) do
    IO.inspect(demand, label: "DEMAND #{state.name}")
    noreply([], state, demand)
  end

  @impl GenStage
  def handle_info(:tick, state = %{demand: 0}) do
    {:noreply, [], %{state | status: :waiting_for_consumers}}
  end

  def handle_info(:tick, state = %{retrieval: event}) when event != nil do
    IO.inspect(event, label: "CONTINUE #{state.name}")
    work_on(event, state)
  end

  def handle_info(:tick, state = %{queue: [event | queue]}) do
    IO.inspect(event, label: "UNQUEUE #{state.name}")
    # work_on(event, %{state | queue: queue})
    noreply([], %{state | retrieval: event, queue: queue})
  end

  def handle_info(:tick, state) do
    producers =
      Enum.into(state.producers, %{}, fn {from, pending} ->
        # Ask for any pending events
        GenStage.ask(from, pending)

        # Reset pending events to 0
        {from, 0}
      end)

    {:noreply, [], %{state | producers: producers, status: :waiting_for_producers}}
  end

  defp work_on(event, state) do
    state = %{state | status: :working}
    IO.inspect(event, label: "EVENT #{state.name}")

    try do
      {events, retrieval} = Weaver.Events.handle(event)
      IO.inspect(events, label: "DISPATCH #{state.name}")
      noreply(events, %{state | retrieval: retrieval})
    rescue
      e in ExTwitter.RateLimitExceededError ->
        IO.inspect(e, label: "PAUSE #{state.name}")
        Process.send_after(self(), :tick, :timer.seconds(e.reset_in))
        {:noreply, [], %{state | status: :paused}, :hibernate}

      e in Dlex.Error ->
        IO.inspect(e, label: "RETRY #{state.name}")
        Process.send_after(self(), :tick, :timer.seconds(5))
        {:noreply, [], %{state | status: :paused}, :hibernate}
    end
  end

  defp noreply(events, state, demand \\ 0) do
    count = length(events)
    new_demand = max(state.demand + demand - count, 0)
    state = %{state | demand: new_demand}
    IO.inspect(new_demand, label: "DEMANDED #{state.name}")
    if new_demand > 0, do: send(self(), :tick)

    {:noreply, events, state}
  end
end
