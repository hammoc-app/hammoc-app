defmodule Hammoc.Scraper.Twitter.Loader do
	use GenStage

	def start_link(profile) do
		IO.puts "profile: #{profile}"
		GenStage.start_link(__MODULE__, %{profile: profile, cursor: nil}, name: __MODULE__)
	end

	def init(state) do
		{:producer, state}
	end

	def handle_demand(demand, %{profile: profile, cursor: nil} = state) when demand > 0 do
    ExTwitter.favorites(screen_name: profile, count: 100) |> handle_tweets(state)

  end

	def handle_demand(demand, %{profile: profile, cursor: cursor} = state) when demand > 0 do
    ExTwitter.favorites(screen_name: profile, count: 100, max_id: cursor) |> handle_tweets(state)

  end

  def handle_tweets(tweets, state) do
    IO.inspect [self(),"I am loading new tweets Fuckers!"]
    min_id_tweet = tweets |> Enum.min_by(fn e -> e.id end)
    new_state = state |> Map.put(:cursor, min_id_tweet.id - 1)
		{:noreply, tweets, new_state}
  end


end
