defmodule Hammoc.Identity.Authentication do
  @moduledoc "An authentication with an external provider, e.g. Twitter."

  use Ecto.Schema

  alias Hammoc.Ecto.{Encrypted, Hashed}
  alias Hammoc.Identity.{User, UserAuthentication}

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields ~w(access_token access_token_secret)a
  @input_fields @required_fields ++ ~w(name first_name last_name nickname image_url)a

  schema "authentications" do
    field :provider, :string
    field :uid, Encrypted.Binary
    field :uid_hash, Hashed.PBKDF2
    field :access_token, Encrypted.Binary
    field :access_token_secret, Encrypted.Binary
    field :name, Encrypted.Binary
    field :first_name, Encrypted.Binary
    field :last_name, Encrypted.Binary
    field :nickname, Encrypted.Binary
    field :image_url, Encrypted.Binary

    timestamps()

    many_to_many :users, User, join_through: UserAuthentication, on_delete: :delete_all
  end

  @doc false
  def changeset(authentication, attrs) do
    authentication
    |> cast(attrs, @input_fields)
    |> cast_image_url(attrs)
    |> validate_required(@required_fields)
    |> put_hashed_fields()
  end

  # allows to pass `image` as alternative key to `image_url`
  defp cast_image_url(changeset, attrs) do
    if get_field(changeset, :image_url) do
      changeset
    else
      put_change(changeset, :image_url, attrs[:image] || attrs["image"])
    end
  end

  # set `uid_hash` if `uid` changed
  defp put_hashed_fields(changeset) do
    changeset
    |> put_change(:uid_hash, get_field(changeset, :uid))
  end
end
