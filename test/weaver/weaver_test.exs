defmodule WeaverTest do
  use ExUnit.Case, async: false

  @query """
  query {
    node(id: "TwitterUser:arnodirlam") {
      id
    }
  }
  """

  @query2 """
  query {
    node(id: "TwitterUser:elixirdigest") {
      ... on TwitterUser {
        id
        screenName
        favorites {
          text
          publishedAt
          user {
            screenName
          }
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

  test "query" do
    # assert Weaver.load_schema()

    query =
      Weaver.query(@query, "Test", %{"id" => "5"})
      |> IO.inspect()

    refute query.result.errors
  end

  test "weave" do
    Weaver.Graph.reset()
    Weaver.weave(@query, "Test", %{"id" => "arnodirlam"})
    :timer.sleep(30000)
  end

  test "weave2" do
    Weaver.Graph.reset()
    Weaver.weave(@query2, "Test", %{"id" => "arnodirlam"})
    :timer.sleep(30000)
  end
end
