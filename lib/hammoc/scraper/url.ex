defmodule Hammoc.Scraper.Url do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hammoc.Scraper.Url


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "urls" do
    field :url, :string

    belongs_to :link, Hammoc.Scraper.Link
  end

  @doc false
  def changeset(%Url{} = url, attrs) do
    url
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
