defmodule HammocWeb.Schema.Types do
  use Absinthe.Schema.Notation
  #use Absinthe.Relay.Schema.Notation, :modern
  use Absinthe.Ecto, repo: Hammoc.Repo

  object :link do
    field :id, :id
    field :title, :string
    field :excerpt, :string

    field :urls, list_of(:url), resolve: assoc(:urls)
  end

  object :url do
    field :url, :string

    field :link, :link, resolve: assoc(:link)
  end
end
