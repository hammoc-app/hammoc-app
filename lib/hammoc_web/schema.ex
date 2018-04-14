defmodule HammocWeb.Schema do
  use Absinthe.Schema
  import_types HammocWeb.Schema.Types

  query do
    field :links, list_of(:link) do
      resolve &Hammoc.Scraper.LinkResolver.all/2
    end

    field :urls, list_of(:url) do
      resolve &Hammoc.Scraper.UrlResolver.all/2
    end
  end
end
