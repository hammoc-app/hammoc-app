defmodule Weaver.EventsTest do
  use ExUnit.Case, async: true

  import Test.Support.Factory
  import Mox

  alias Weaver.{Cursor, Events, Graph, Ref}
  alias Weaver.ExTwitter.Mock, as: Twitter

  @query """
  query {
    node(id: "TwitterUser:elixirdigest") {
      ... on TwitterUser {
        id
        screenName
        favoritesCount
        favorites {
          text
          publishedAt
          user {
            screenName
          }
          retweetsCount
          retweets {
            text
            publishedAt
            user {
              screenName
            }
          }
        }
      }
    }
  }
  """

  setup tags do
    user = build(ExTwitter.Model.User, screen_name: "elixirdigest")
    favorites = build(ExTwitter.Model.Tweet, 10, fn i -> [id: 11 - i] end) |> IO.inspect()

    {:ok, user: user, favorites: favorites}
  end

  test "", %{user: user, favorites: favorites} do
    {ast, fun_env} = Weaver.parse_query(@query)
    event = %Weaver.Tree{ast: ast, fun_env: fun_env}

    expect(Twitter, :user, fn "elixirdigest" -> user end)
    result = Events.handle(event)
    verify!()

    assert {[event2], nil} = result

    assert %{ast: {:retrieve, :favorites, _ast, "favorites"}, cursor: nil, gap: :not_loaded} =
             event2

    assert user == event2.data

    # favorites initial
    expect(Twitter, :favorites, fn [id: user_id, tweet_mode: :extended, count: count] ->
      assert user_id == user.id
      Enum.take(favorites, count)
    end)

    result = Events.handle(event2)
    verify!()

    assert {[event3a, event3b], event2_} = result

    assert %{ast: {:retrieve, :favorites, _ast, "favorites"}, cursor: %Cursor{val: 10}, gap: nil} =
             event2_

    assert {:retrieve, :retweets, _ast, "retweets"} = event3a.ast
    assert Enum.at(favorites, 0) == event3a.data
    assert Enum.at(favorites, 1) == event3b.data

    # favorites pt. 2
    expect(Twitter, :favorites, fn [id: user_id, tweet_mode: :extended, count: count, max_id: 9] ->
      assert user_id == user.id
      Enum.slice(favorites, 2, count)
    end)

    result = Events.handle(event2_)
    verify!()

    assert {[event3c, event3d], event2__} = result

    assert %{ast: {:retrieve, :favorites, _ast, "favorites"}, cursor: %Cursor{val: 8}} = event2__

    assert {:retrieve, :retweets, _ast, "retweets"} = event3c.ast
    assert Enum.at(favorites, 2) == event3c.data
    assert Enum.at(favorites, 3) == event3d.data
  end
end
