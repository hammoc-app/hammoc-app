defmodule Hammoc.Identity.User do
  @moduledoc "A user, linked to one or multiple authentications."

  use Ecto.Schema

  alias Hammoc.Ecto.{Encrypted, Hashed}
  alias Hammoc.Identity.{Authentication, UserAuthentication}

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, Encrypted.Binary
    field :email_hash, Hashed.PBKDF2
    field :newsletter, :boolean

    timestamps()

    many_to_many :authentications, Authentication,
      join_through: UserAuthentication,
      on_delete: :delete_all
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :newsletter])
    |> validate_required([])
    |> put_hashed_fields()
  end

  defp put_hashed_fields(changeset) do
    changeset
    |> put_change(:email_hash, get_field(changeset, :email))
  end
end
