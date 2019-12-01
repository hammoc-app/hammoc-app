defmodule Hammoc.Retriever.Client.Fixtures do
  @moduledoc "Retrieves Tweets from a local fixtures file."

  use GenServer

  alias Hammoc.Retriever.Client
  alias Hammoc.Retriever.Status.Job

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

  @impl GenServer
  def init(_args) do
    remaining_tweets =
      [File.cwd!(), "priv", "fixtures", "favourites.json"]
      |> Path.join()
      |> File.read!()
      |> Jason.decode!()
      |> Util.Map.deep_atomize_keys()

    {:ok, %{total_count: length(remaining_tweets), remaining_tweets: remaining_tweets}}
  end

  @impl GenServer
  def handle_call(:init, _from, state) do
    retrieval_job = %Job{channel: "Twitter Favorites", current: 0, max: state.total_count}

    {:reply, {:ok, retrieval_job}, state}
  end

  def handle_call({:next_batch, retrieval_job}, _from, state = %{remaining_tweets: []}) do
    {:reply, {:ok, [], retrieval_job}, state}
  end

  def handle_call(
        {:next_batch, retrieval_job},
        _from,
        state = %{remaining_tweets: [loaded_tweet | remaining_tweets]}
      ) do
    new_state =
      state
      |> Map.put(:remaining_tweets, remaining_tweets)

    :timer.sleep(1000)

    {:reply, {:ok, [loaded_tweet], retrieval_job}, new_state}
  end
end
