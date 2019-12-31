defmodule Weaver.GenStage.Consumer do
  use GenStage

  @max_demand 1

  def start_link(opts = {name, _subscriptions}) do
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  @impl GenStage
  def init({name, subscriptions}) do
    subscriptions =
      Enum.map(subscriptions, fn
        {name, opts} -> {name, Keyword.put_new(opts, :max_demand, @max_demand)}
        name -> {name, max_demand: @max_demand}
      end)

    {:consumer, %{name: name}, subscribe_to: subscriptions}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    {[], nil} = handle_remaining(events, state)
    {:noreply, [], state}
  end

  defp handle_remaining(events, state = %{retrieval: event}) when event != nil do
    {new_events, state} = Weaver.Events.do_handle(event, state)
    handle_remaining(new_events ++ events, state)
  end

  defp handle_remaining([event | events], state) do
    IO.inspect(event, label: "EVENT #{state.name}")
    {new_events, state} = Weaver.Events.do_handle(event, state)
    IO.inspect(new_events, label: "DISPATCH #{state.name}")
    IO.inspect(state, label: "STATE #{state.name}")
    handle_remaining(new_events ++ events, state)
  end

  defp handle_remaining([], state) do
    {[], state}
  end
end
