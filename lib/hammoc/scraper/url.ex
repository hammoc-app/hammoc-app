defmodule Hammoc.Scraper.Url do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hammoc.Scraper.Url


  @primary_key {:url, :string, autogenerate: false}
  @foreign_key_type :string
  schema "urls" do
    belongs_to :link, Hammoc.Scraper.Link, type: Ecto.UUID
  end

  @doc false
  def changeset(%Url{} = url, attrs) do
    url
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
