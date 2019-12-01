defmodule Hammoc.Retriever.Client.Twitter do
  @moduledoc "Retrieves Tweets from the Twitter API."

  alias Hammoc.Retriever.Client
  alias Hammoc.Retriever.Status.Job

  @behaviour Client

  @impl Client
  def init() do
    # returns a ExTwitter.Model.User
    twitter_user = ExTwitter.user("arnodirlam")

    retrieval_job = %Job{
      channel: "Twitter Favorites",
      current: 0,
      max: twitter_user.favourites_count
    }

    {:ok, retrieval_job}
  end

  @impl Client
  def next_batch(job = %Job{extra: %{min_id: min_id}}) do
    # returns a List of ExTwitter.Model.Tweet
    ExTwitter.favorites(screen_name: "arnodirlam", count: 200, max_id: min_id - 1)
    |> do_next_batch(job)
  end

  def next_batch(job) do
    # returns a List of ExTwitter.Model.Tweet
    ExTwitter.favorites(screen_name: "arnodirlam", count: 200)
    |> do_next_batch(job)
  end

  defp do_next_batch(tweets, job) do
    min_id = tweets |> Enum.map(& &1.id) |> Enum.min(fn -> nil end)
    retrieval_job = %{job | extra: %{min_id: min_id}}
    {:ok, normalize(tweets), retrieval_job}
  end

  defp normalize(tweets) do
    tweets
    |> Enum.map(&Map.from_struct/1)
  end
end
