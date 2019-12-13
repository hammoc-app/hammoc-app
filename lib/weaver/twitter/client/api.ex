defmodule Weaver.Twitter.Client.API do
  @behaviour Weaver.Twitter.Client

  @impl true
  def favorites(id, max_id \\ nil)

  def favorites(id, nil) do
    ExTwitter.Parser.parse_request_params(id: id, count: 200)
    |> retrieve_favorites(id)
  end

  def favorites(id, max_id) do
    ExTwitter.Parser.parse_request_params(id: id, count: 200, max_id: max_id)
    |> retrieve_favorites(id)
  end

  defp retrieve_favorites(params, id) do
    case ExTwitter.API.Base.request(:get, "1.1/favorites/list.json", params) do
      [] ->
        []

      tweets ->
        min_id = tweets |> Enum.map(& &1["id"]) |> Enum.min(fn -> nil end)
        parse_tweets(tweets) ++ favorites(id, min_id - 1)
    end
  end

  defp parse_tweets(tweets) do
    Enum.map(tweets, &parse_tweet/1)
  end

  defp parse_tweet(tweet) do
    tweet = struct(Weaver.Twitter.Tweet, tweet)
    user = parse_user(tweet.user)
    %{tweet | user: user}
  end

  defp parse_user(user) do
    struct(Weaver.Twitter.User, user)
  end
end
