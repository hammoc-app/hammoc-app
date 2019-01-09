defmodule Hammoc.Scraper.Link do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hammoc.Scraper.Link


  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "links" do
    field :excerpt, :string
    field :html, :string
    field :keywords, {:array, :string}
    field :main_url, :string
    field :title, :string

    has_many :urls, Hammoc.Scraper.Url, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Link{} = link, attrs) do
    link
    |> cast(attrs, [:main_url, :title, :excerpt, :html, :keywords])
    |> nullify_empty_keywords()
    |> validate_required([:main_url])
  end

  @doc "Set keywords to `nil` if it's an empty array, for compatibility with Cockroach DB."
  def nullify_empty_keywords(%Ecto.Changeset{changes: %{keywords: []}} = changeset) do
    put_in(changeset.changes.keywords, nil)
  end

  def nullify_empty_keywords(changeset), do: changeset
end
