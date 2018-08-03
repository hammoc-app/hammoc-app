defmodule Hammoc.Scraper.Twitter.Loader do
	use GenStage

	def start_link(profile) do
		IO.puts "profile: #{profile}"
		GenStage.start_link(__MODULE__, %{profile: profile, cursor: nil}, name: __MODULE__)
	end

	def init(state) do
		{:producer, state}
	end

	def handle_demand(demand, %{profile: profile, cursor: _cursor} = state) when demand > 0 do
    tweets = ExTwitter.favorites(screen_name: profile, count: 100)

    IO.inspect [self(),"I am loading new tweets Fuckers!"]

		{:noreply, tweets, state}
	end

end
