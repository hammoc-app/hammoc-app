defmodule Hammoc.Scraper.Twitter.Collector do
	use GenStage

	def start_link do
		GenStage.start_link(__MODULE__, nil)
	end

	def init(nil) do
		{:consumer, nil, subscribe_to: [{Hammoc.Scraper.Twitter.Loader, max_demand: 20}]}
	end

	def handle_events(tweets, _from, state) do
		new_tweets = tweets |> Enum.map(fn e -> e.text end)
		new_tweets |> Enum.each(fn t -> IO.inspect([self(),t]) end)

		IO.inspect [self(),"sleeping for 10s"]
		:timer.sleep(10_000)
		IO.inspect [self(),"awake"]

		{:noreply, [], state}
	end

end
