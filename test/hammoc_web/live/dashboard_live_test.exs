defmodule HammocWeb.DashboardLiveTest do
  use HammocWeb.LiveIntegrationCase, async: false

  defp tweets(index_or_range) do
    [File.cwd!(), "priv", "fixtures", "favourites.json"]
    |> Path.join()
    |> File.read!()
    |> Jason.decode!()
    |> Util.Enum.slice(index_or_range)
    |> Util.Map.deep_atomize_keys()
  end

  test "shows retrieved Tweets", %{conn: conn} do
    conn
    |> live("/dashboard")
    |> init_retrieval(2)
    |> refute_rendered(
      body: "If you lead development teams, you need to read this",
      body: "How we deal with behaviours and boilerplate"
    )
    |> next_retrieval(tweets(0))
    |> assert_rendered(element: ["progress[value=1][max=2]", text: "1/2"])
    |> assert_rendered(body: "If you lead development teams, you need to read this")
    |> refute_rendered(body: "How we deal with behaviours and boilerplate")
    |> next_retrieval(tweets(1))
    |> assert_rendered(body: "If you lead development teams, you need to read this")
    |> assert_rendered(body: "How we deal with behaviours and boilerplate")
    |> finish_retrieval()
    |> refute_rendered(element: "progress")
    |> assert_rendered(body: "If you lead development teams, you need to read this")
    |> assert_rendered(body: "How we deal with behaviours and boilerplate")
  end
end
