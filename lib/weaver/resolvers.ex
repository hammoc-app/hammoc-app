defmodule Weaver.Resolvers do
  @api_count 200
  @api_take 200

  def retrieve_by_id("TwitterUser:" <> id) do
    ExTwitter.user(id)
  end

  def id_for(obj = %ExTwitter.Model.User{}), do: "TwitterUser:#{obj.screen_name}"
  def id_for(obj = %ExTwitter.Model.Tweet{}), do: "Tweet:#{obj.id_str}"

  def resolve_leaf(obj = %ExTwitter.Model.User{}, "id") do
    obj.id
  end

  def resolve_leaf(obj = %ExTwitter.Model.User{}, "screenName") do
    obj.screen_name
  end

  def resolve_leaf(obj = %ExTwitter.Model.Tweet{}, "text") do
    obj.full_text
  end

  def resolve_leaf(obj = %ExTwitter.Model.Tweet{}, "publishedAt") do
    obj.created_at
  end

  def resolve_leaf(obj = %ExTwitter.Model.Tweet{}, "likesCount") do
    obj.favorite_count
  end

  def resolve_leaf(obj = %ExTwitter.Model.Tweet{}, "retweetsCount") do
    obj.retweet_count
  end

  def resolve_node(obj = %ExTwitter.Model.User{}, "favorites") do
    {:retrieve, obj, :favorites}
  end

  def resolve_node(obj = %ExTwitter.Model.User{}, "tweets") do
    {:retrieve, obj, :tweets}
  end

  def resolve_node(obj = %ExTwitter.Model.User{}, "retweets") do
    {:retrieve, obj, :retweets}
  end

  def resolve_node(obj = %ExTwitter.Model.Tweet{}, "user") do
    obj.user
  end

  def resolve_node(obj = %ExTwitter.Model.Tweet{}, "retweetOf") do
    obj.retweeted_status
  end

  def resolve_node(obj = %ExTwitter.Model.Tweet{}, "likes") do
    {:retrieve, obj, :likes}
  end

  def resolve_node(obj = %ExTwitter.Model.Tweet{}, "replies") do
    {:retrieve, obj, :replies}
  end

  def resolve_node(obj = %ExTwitter.Model.Tweet{}, "retweets") do
    {:retrieve, obj, :retweets}
  end

  def resolve_node(obj = %ExTwitter.Model.Tweet{}, "mentions") do
    {:retrieve, obj, :mentions}
  end

  def total_count(obj = %ExTwitter.Model.User{}, "favorites") do
    obj.favourites_count
  end

  def total_count(obj = %ExTwitter.Model.Tweet{}, "likesCount") do
    obj.favorite_count
  end

  def total_count(obj = %ExTwitter.Model.Tweet{}, "retweetsCount") do
    obj.retweet_count
  end

  def total_count(_obj, _relation), do: nil

  def retrieve(obj = %ExTwitter.Model.User{}, :favorites, cursor) do
    tweets =
      case cursor do
        nil ->
          ExTwitter.favorites(id: obj.id, tweet_mode: :extended, count: @api_count)

        min_id ->
          ExTwitter.favorites(
            id: obj.id,
            tweet_mode: :extended,
            count: @api_count,
            max_id: min_id - 1
          )
      end

    case tweets do
      [] ->
        {:done, []}

      tweets ->
        min_id = Enum.min_by(tweets, & &1.id).id
        {:continue, Enum.take(tweets, @api_take), min_id}
    end
  end

  def retrieve(obj = %ExTwitter.Model.User{}, :tweets, cursor) do
    tweets =
      case cursor do
        nil ->
          ExTwitter.user_timeline(
            screen_name: obj.screen_name,
            include_rts: false,
            tweet_mode: :extended,
            count: @api_count
          )

        min_id ->
          ExTwitter.user_timeline(
            screen_name: obj.screen_name,
            include_rts: false,
            tweet_mode: :extended,
            count: @api_count,
            max_id: min_id - 1
          )
      end

    case tweets do
      [] ->
        {:done, []}

      tweets ->
        min_id = Enum.min_by(tweets, & &1.id).id
        {:continue, Enum.take(tweets, @api_take), min_id}
    end
  end

  def retrieve(obj = %ExTwitter.Model.User{}, :retweets, cursor) do
    tweets =
      case cursor do
        nil ->
          ExTwitter.user_timeline(
            screen_name: obj.screen_name,
            tweet_mode: :extended,
            count: @api_count
          )

        min_id ->
          ExTwitter.user_timeline(
            screen_name: obj.screen_name,
            tweet_mode: :extended,
            count: @api_count,
            max_id: min_id - 1
          )
      end

    case tweets do
      [] ->
        {:done, []}

      tweets ->
        min_id = Enum.min_by(tweets, & &1.id).id

        tweets =
          tweets
          |> Enum.filter(& &1.retweeted_status)
          |> Enum.take(@api_take)

        {:continue, tweets, min_id}
    end
  end

  def retrieve(%ExTwitter.Model.Tweet{}, :likes, _cursor) do
    {:done, []}
  end

  def retrieve(%ExTwitter.Model.Tweet{}, :replies, _cursor) do
    {:done, []}
  end

  def retrieve(obj = %ExTwitter.Model.Tweet{}, :retweets, cursor) do
    tweets =
      case cursor do
        nil ->
          ExTwitter.retweets(obj.id, count: @api_count, tweet_mode: :extended)

        min_id ->
          ExTwitter.retweets(obj.id, count: @api_count, tweet_mode: :extended, max_id: min_id - 1)
      end

    case tweets do
      [] ->
        {:done, []}

      tweets ->
        min_id = Enum.min_by(tweets, & &1.id).id
        {:continue, Enum.take(tweets, @api_take), min_id}
    end
  end

  def retrieve(obj = %ExTwitter.Model.Tweet{}, :mentions, _cursor) do
    users =
      case obj.entities.user_mentions do
        [] -> []
        mentions -> mentions |> Enum.map(& &1.id) |> ExTwitter.user_lookup()
      end

    {:done, users}
  end
end
