defmodule Hammoc.Scraper.UrlResolver do
  alias Hammoc.{Scraper.Url, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Url)}
  end
end
