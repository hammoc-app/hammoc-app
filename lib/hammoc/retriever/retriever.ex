defmodule Hammoc.Retriever do
  @moduledoc "Retrieves Tweets from the Twitter API."

  use GenServer

  alias Hammoc.Retriever.Status

  @search Application.get_env(:hammoc, Hammoc.Search)[:module]
  @client Application.get_env(:hammoc, Hammoc.Retriever)[:client_module]

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def subscribe() do
    GenServer.call(__MODULE__, :subscribe)
  end

  @impl GenServer
  def init(_args) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call(:subscribe, {pid, _ref}, nil) do
    {:ok, retrieval_job} = @client.init()
    send(self(), :tick)

    {:reply, :ok, %{subscribers: [pid], retrieval_jobs: [retrieval_job]}}
  end

  def handle_call(:subscribe, {pid, _ref}, state) do
    new_state = Map.put(state, :subscribers, [pid | state.subscribers])
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_info(:tick, state = %{retrieval_jobs: [retrieval_job]}) do
    {:ok, tweets, new_retrieval_job} = @client.next_batch(retrieval_job)

    new_retrieval_jobs =
      case tweets do
        [] ->
          []

        _ ->
          send(self(), :tick)
          [new_retrieval_job]
      end

    new_state =
      state
      |> Map.put(:retrieval_jobs, new_retrieval_jobs)
      |> loaded_tweets(tweets)
      |> notify_subscribers()

    {:noreply, new_state}
  end

  defp loaded_tweets(state, tweets) do
    @search.index(tweets)

    state
  end

  defp notify_subscribers(state) do
    retrieval_info = %Status{jobs: state.retrieval_jobs}

    Enum.each(state.subscribers, fn pid ->
      send(pid, {:retrieval_progress, retrieval_info})
    end)

    state
  end
end
