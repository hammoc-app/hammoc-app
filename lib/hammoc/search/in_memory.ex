defmodule Hammoc.Search.InMemory do
  @moduledoc "A basic in-memory search index."

  use GenServer

  alias Hammoc.Search
  alias Hammoc.Search.Facets
  alias Hammoc.Search.InMemory.Autocomplete

  @behaviour Search

  @impl Search
  def index(tweets) do
    GenServer.call(__MODULE__, {:index, tweets})
  end

  @impl Search
  def total_count() do
    GenServer.call(__MODULE__, :total_count)
  end

  @impl Search
  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  @impl Search
  def query(facets) do
    GenServer.call(__MODULE__, {:query, facets})
  end

  @impl Search
  def top_hashtags(facets) do
    GenServer.call(__MODULE__, {:top_hashtags, facets})
  end

  @impl Search
  def top_profiles(facets) do
    GenServer.call(__MODULE__, {:top_profiles, facets})
  end

  @impl Search
  def autocomplete(query) do
    if query && String.length(query) >= 3 do
      GenServer.call(__MODULE__, {:autocomplete, query})
    else
      {:ok, nil}
    end
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    {:ok, []}
  end

  @impl GenServer
  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  @impl GenServer
  def handle_call({:index, tweets}, _from, state) do
    {:reply, :ok, state ++ tweets}
  end

  @impl GenServer
  def handle_call(:total_count, _from, state) do
    {:reply, {:ok, length(state)}, state}
  end

  def handle_call({:query, facets}, _from, state) do
    paginator =
      state
      |> filter_by(facets)
      |> Scrivener.paginate(page: facets.page, page_size: 2)

    {:reply, {:ok, paginator}, state}
  end

  def handle_call({:top_hashtags, facets}, _from, state) do
    based_on =
      if facets.hashtags do
        state
      else
        filter_by(state, facets)
      end

    top_hashtags =
      based_on
      |> Enum.flat_map(& &1.entities.hashtags)
      |> ranked_options(facets.hashtags, & &1.text)

    {:reply, {:ok, top_hashtags}, state}
  end

  def handle_call({:top_profiles, facets}, _from, state) do
    based_on =
      if facets.profiles do
        state
      else
        filter_by(state, facets)
      end

    top_profiles =
      based_on
      |> ranked_options(facets.profiles, & &1.user.screen_name)
      |> Enum.map(&find_profile(&1, state))

    {:reply, {:ok, top_profiles}, state}
  end

  def handle_call({:autocomplete, query}, _from, state) do
    suggestions = Autocomplete.for(state, & &1.text, query)

    {:reply, {:ok, suggestions}, state}
  end

  defp find_profile(screen_name, tweets) do
    Enum.find_value(tweets, fn tweet ->
      if tweet.user.screen_name == screen_name, do: tweet.user
    end)
  end

  defp filter_by(tweets, facets) do
    tweets
    |> Facets.filter_by(facets.hashtags, fn tweet ->
      Enum.map(tweet.entities.hashtags, & &1.text)
    end)
    |> Facets.filter_by(facets.profiles, & &1.user.screen_name)
    |> Facets.filter_by(facets.query, & &1.text)
  end

  defp ranked_options(options, selected_options, mapper) do
    options
    |> Util.Enum.count(mapper)
    |> Util.Enum.top_counts(5)
    |> Enum.map(&elem(&1, 0))
    |> Util.List.prepend(selected_options)
    |> Enum.uniq()
    |> Enum.take(5)
  end
end
