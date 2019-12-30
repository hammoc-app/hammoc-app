defmodule Weaver.Resolvers do
  alias Weaver.{Cursor, Ref}
  alias ExTwitter.Model.{Tweet, User}

  @twitter_client Application.get_env(:hammoc, Weaver.Twitter)[:client_module]
  @api_count Application.get_env(:hammoc, Weaver.Twitter)[:api_count]
  @api_take Application.get_env(:hammoc, Weaver.Twitter)[:api_take]

  def retrieve_by_id("TwitterUser:" <> id) do
    @twitter_client.user(id)
  end

  def id_for(obj = %User{}), do: "TwitterUser:#{obj.screen_name}"
  def id_for(obj = %Tweet{}), do: "Tweet:#{obj.id_str}"

  def cursor(objs) when is_list(objs) do
    objs
    |> Enum.min_by(& &1.id)
    |> cursor()
  end

  def cursor(obj) do
    id = id_for(obj)
    ref = Ref.new(id)
    Cursor.new(ref, obj.id)
  end

  def resolve_leaf(obj = %User{}, "screenName") do
    obj.screen_name
  end

  def resolve_leaf(obj = %User{}, "favoritesCount") do
    obj.favourites_count
  end

  def resolve_leaf(obj = %Tweet{}, "text") do
    obj.full_text
  end

  def resolve_leaf(obj = %Tweet{}, "publishedAt") do
    obj.created_at
  end

  def resolve_leaf(obj = %Tweet{}, "likesCount") do
    obj.favorite_count
  end

  def resolve_leaf(obj = %Tweet{}, "retweetsCount") do
    obj.retweet_count
  end

  def resolve_node(obj = %User{}, "favorites") do
    {:retrieve, obj, :favorites}
  end

  def resolve_node(obj = %User{}, "tweets") do
    {:retrieve, obj, :tweets}
  end

  def resolve_node(obj = %User{}, "retweets") do
    {:retrieve, obj, :retweets}
  end

  def resolve_node(obj = %Tweet{}, "user") do
    obj.user
  end

  def resolve_node(obj = %Tweet{}, "retweetOf") do
    obj.retweeted_status
  end

  def resolve_node(obj = %Tweet{}, "likes") do
    {:retrieve, obj, :likes}
  end

  def resolve_node(obj = %Tweet{}, "replies") do
    {:retrieve, obj, :replies}
  end

  def resolve_node(obj = %Tweet{}, "retweets") do
    {:retrieve, obj, :retweets}
  end

  def resolve_node(obj = %Tweet{}, "mentions") do
    {:retrieve, obj, :mentions}
  end

  def total_count(obj = %User{}, "favorites") do
    obj.favourites_count
  end

  def total_count(obj = %Tweet{}, "likesCount") do
    obj.favorite_count
  end

  def total_count(obj = %Tweet{}, "retweetsCount") do
    obj.retweet_count
  end

  def total_count(_obj, _relation), do: nil

  def retrieve(obj = %User{}, :favorites, cursor) do
    tweets =
      case cursor do
        nil ->
          @twitter_client.favorites(id: obj.id, tweet_mode: :extended, count: @api_count)

        %Cursor{val: min_id} ->
          @twitter_client.favorites(
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
        {:continue, Enum.take(tweets, @api_take), cursor(tweets)}
    end
  end

  def retrieve(obj = %User{}, :tweets, cursor) do
    tweets =
      case cursor do
        nil ->
          @twitter_client.user_timeline(
            screen_name: obj.screen_name,
            include_rts: false,
            tweet_mode: :extended,
            count: @api_count
          )

        min_id ->
          @twitter_client.user_timeline(
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
        {:continue, Enum.take(tweets, @api_take), cursor(tweets)}
    end
  end

  def retrieve(obj = %User{}, :retweets, cursor) do
    tweets =
      case cursor do
        nil ->
          @twitter_client.user_timeline(
            screen_name: obj.screen_name,
            tweet_mode: :extended,
            count: @api_count
          )

        min_id ->
          @twitter_client.user_timeline(
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
        tweets =
          tweets
          |> Enum.filter(& &1.retweeted_status)
          |> Enum.take(@api_take)

        {:continue, tweets, cursor(tweets)}
    end
  end

  def retrieve(%Tweet{}, :likes, _cursor) do
    {:done, []}
  end

  def retrieve(%Tweet{}, :replies, _cursor) do
    {:done, []}
  end

  def retrieve(obj = %Tweet{}, :retweets, cursor) do
    tweets =
      case cursor do
        nil ->
          @twitter_client.retweets(obj.id, count: @api_count, tweet_mode: :extended)

        min_id ->
          @twitter_client.retweets(obj.id,
            count: @api_count,
            tweet_mode: :extended,
            max_id: min_id - 1
          )
      end

    case tweets do
      [] ->
        {:done, []}

      tweets ->
        {:continue, Enum.take(tweets, @api_take), cursor(tweets)}
    end
  end

  def retrieve(obj = %Tweet{}, :mentions, _cursor) do
    users =
      case obj.entities.user_mentions do
        [] -> []
        mentions -> mentions |> Enum.map(& &1.id) |> @twitter_client.user_lookup()
      end

    {:done, users}
  end
end
