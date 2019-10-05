defmodule Hammoc.Identity.UserAuthentication do
  @moduledoc "Link between a `User` and an `Authentication`."

  use Ecto.Schema

  alias Hammoc.Identity.{Authentication, User}

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  @required_fields [:user_id, :authentication_id]

  schema "users_authentications" do
    belongs_to :user, User, primary_key: true
    belongs_to :authentication, Authentication, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(user_authentication, attrs) do
    user_authentication
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
