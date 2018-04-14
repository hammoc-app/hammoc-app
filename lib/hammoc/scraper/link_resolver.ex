defmodule Hammoc.Scraper.LinkResolver do
  alias Hammoc.{Scraper.Link, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Link)}
  end
end
