defmodule Hammoc.IdentityTest do
  use Hammoc.DataCase

  alias Hammoc.Identity
  alias Hammoc.Identity.{Authentication, User, UserAuthentication}

  describe "authenticate_via_oauth, not signed in" do
    test "returns the same authentication twice" do
      fields = fields_for(Authentication)

      {:ok, [record]} =
        Identity.authenticate_via_oauth(nil, fields.provider, fields.uid, %{
          access_token: fields.access_token,
          access_token_secret: fields.access_token_secret,
          nickname: fields.nickname
        })

      assert_nested(%{authentications: [fields]}, record)

      {:ok, [record2]} =
        Identity.authenticate_via_oauth(nil, fields.provider, fields.uid, %{
          access_token: fields.access_token,
          access_token_secret: fields.access_token_secret,
          nickname: fields.nickname
        })

      assert_nested(%{authentications: [fields]}, record2)

      assert record.id == record2.id
    end

    test "preloads users" do
      user = create!(User)
      auth = create!(Authentication)
      create!(UserAuthentication, user_id: user.id, authentication_id: auth.id)

      {:ok, [record]} =
        Identity.authenticate_via_oauth(
          nil,
          auth.provider,
          auth.uid,
          Map.take(auth, [:access_token, :access_token_secret])
        )

      assert_nested(%{id: user.id, email: user.email}, record)
    end
  end
end
