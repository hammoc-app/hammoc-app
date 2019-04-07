defmodule Hammoc.IdentityTest do
  use Hammoc.DataCase

  alias Hammoc.Identity
  alias Hammoc.Identity.{Authentication, User, UserAuthentication}

  describe "authenticate_via_oauth" do
    test "returns the same authentication twice" do
      fields = fields_for(Authentication)

      {:ok, record} =
        Identity.authenticate_via_oauth(fields.provider, fields.uid, %{
          access_token: fields.access_token,
          access_token_secret: fields.access_token_secret,
          nickname: fields.nickname
        })

      assert fields = record

      {:ok, record2} =
        Identity.authenticate_via_oauth(fields.provider, fields.uid, %{
          access_token: fields.access_token,
          access_token_secret: fields.access_token_secret,
          nickname: fields.nickname
        })

      assert fields = record2

      assert record == record2
    end

    test "preloads users" do
      user = create!(User)
      auth = create!(Authentication)
      create!(UserAuthentication, user_id: user.id, authentication_id: auth.id)

      {:ok, record} =
        Identity.authenticate_via_oauth(
          auth.provider,
          auth.uid,
          Map.take(auth, [:access_token, :access_token_secret])
        )

      user_id = user.id
      user_email = user.email
      assert [%User{id: ^user_id, email: ^user_email}] = record.users
    end
  end
end
