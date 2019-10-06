defmodule HammocWeb.PageView do
  use HammocWeb, :view

  @url_regex ~r/(https?:\/\/)?([\w\-]\.)+[a-zA-Z]{2,}(\/\S*)?/u
  @hashtag_regex ~r/#(\S+)/u
  @cashtag_regex ~r/\$(\S+)/u
  @mention_regex ~r/@(\S+)/u

  def checked(option, options, output \\ " checked=\"checked\"")

  def checked(_option, nil, _output), do: ""

  def checked(option, options, output) do
    if option in options do
      output
    else
      ""
    end
  end

  @doc """
  Formats a datetime String from Twitter.

  ## Examples

      iex> "Sat Aug 03 17:45:10 +0000 2019"
      ...> |> Hammoc.PageView.format_twitter_datetime()
      "17:45 - Aug 03, 2019"
  """
  def format_twitter_datetime(str) do
    [_weekday, month, day, time, _zone, year] = String.split(str)
    [hour, minute, _second] = String.split(time, ":")
    "#{hour}:#{minute} - #{month} #{day}, #{year}"
  end

  @doc ~S"""
  Convert URLs in text to HTML link tags.

  ## Examples

      iex> "Use Phoenix LiveView to Enhance Observability by @dsdshcym https://t.co/2eFjf24fT2 /cc $elixirweekly #elixirlang"
      ...> |> Hammoc.PageView.auto_link()
      "Use Phoenix LiveView to Enhance Observability by " <>
        "<a href=\"https://twitter.com/dsdshcym\">@dsdshcym</a> " <>
        "<a href=\"https://t.co/2eFjf24fT2\">https://t.co/2eFjf24fT2</a> " <>
        "/cc <a href=\"https://twitter.com/search?q=%24elixirweekly\">$elixirweekly</a> " <>
        "<a href=\"https://twitter.com/search?q=%23elixirlang\">#elixirlang</a>"

      iex> "Looking for an Elixir challenge to stretch your development skills? Join Phoenix Phrenzy and see what’s possible.… https://t.co/DVa2gpzPHk"
      ...> |> Hammoc.PageView.auto_link()
      "Looking for an Elixir challenge to stretch your development skills? Join Phoenix Phrenzy and see what’s possible.… " <>
        "<a href=\"https://t.co/DVa2gpzPHk\">https://t.co/DVa2gpzPHk</a>"
  """
  def auto_link(text) do
    text
    |> String.replace(@url_regex, "<a href=\"\\0\">\\0</a>")
    |> String.replace(@hashtag_regex, "<a href=\"https://twitter.com/search?q=%23\\1\">\\0</a>")
    |> String.replace(@cashtag_regex, "<a href=\"https://twitter.com/search?q=%24\\1\">\\0</a>")
    |> String.replace(@mention_regex, "<a href=\"https://twitter.com/\\1\">\\0</a>")
  end
end
