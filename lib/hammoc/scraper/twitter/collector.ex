defmodule Hammoc.Scraper.Twitter.Collector do
  @moduledoc "GenStage consumer that prints the retrieved Tweets to console."

  use GenStage

  def start_link(_arg) do
    GenStage.start_link(__MODULE__, nil)
  end

  def init(nil) do
    {:consumer, nil, subscribe_to: [{Hammoc.Scraper.Twitter.Loader, max_demand: 20}]}
  end

  def handle_events(tweets, _from, state) do
    tweets
    |> Enum.each(fn tweet -> IO.puts("$#{tweet.id_str} #{tweet.created_at} #{tweet.text}") end)

    :timer.sleep(10_000)

    {:noreply, [], state}
  end
end
