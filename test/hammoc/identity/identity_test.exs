defmodule Hammoc.IdentityTest do
  use Hammoc.DataCase

  alias Hammoc.Identity
  alias Hammoc.Identity.{Authentication, User, UserAuthentication}

  def with_users(_context) do
    other_user = create!(User, authentications: [])
    user = create!(User, authentications: [])

    %{other_user: other_user, user: user}
  end

  def with_user_authentications(context) do
    %{other_user: other_user, user: user} = with_users(context)

    auth = create!(Authentication)
    create!(UserAuthentication, user_id: user.id, authentication_id: auth.id)

    other_auth = create!(Authentication)
    create!(UserAuthentication, user_id: other_user.id, authentication_id: other_auth.id)

    %{
      user: %{user | authentications: [auth]},
      other_user: %{other_user | authentications: [other_auth]}
    }
  end

  describe "get & update users" do
    setup :with_users

    def expected_user_fields(user) do
      user
      |> Map.from_struct()
      |> Map.delete(:email_hash)
    end

    test "get user", %{user: user} do
      assert_nested({:ok, expected_user_fields(user)}, Identity.get_user(user.id))
    end

    test "update user", %{user: user} do
      assert {:ok, _user} = Identity.update_user(user, %{email: "olivia@queer.net"})

      assert_nested({:ok, %{email: "olivia@queer.net"}}, Identity.get_user(user.id))
    end

    test "get users", %{user: user, other_user: other_user} do
      users = Identity.get_users([user.id, other_user.id])

      assert_nested({:ok, [expected_user_fields(other_user), expected_user_fields(user)]}, users)
    end
  end

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

  describe "authenticate_via_oauth, signed in" do
    setup :with_users

    test "returns the same authentication twice", %{user: user} do
      fields = fields_for(Authentication)

      {:ok, [record]} =
        Identity.authenticate_via_oauth(user, fields.provider, fields.uid, %{
          access_token: fields.access_token,
          access_token_secret: fields.access_token_secret,
          nickname: fields.nickname
        })

      assert_nested(%{id: user.id, authentications: [fields]}, record)

      {:ok, [record2]} =
        Identity.authenticate_via_oauth(user, fields.provider, fields.uid, %{
          access_token: fields.access_token,
          access_token_secret: fields.access_token_secret,
          nickname: fields.nickname
        })

      assert_nested(%{id: user.id, authentications: [fields]}, record2)
    end

    test "preloads users", %{user: user} do
      auth = create!(Authentication)
      create!(UserAuthentication, user_id: user.id, authentication_id: auth.id)

      {:ok, [record]} =
        Identity.authenticate_via_oauth(
          user,
          auth.provider,
          auth.uid,
          Map.take(auth, [:access_token, :access_token_secret])
        )

      assert_nested(%{id: user.id, email: user.email}, record)
    end
  end

  describe "remove user authentication" do
    setup :with_user_authentications

    test "removes existing authentication from user", %{user: user = %{authentications: [auth]}} do
      Identity.remove_user_authentication(user, auth)

      assert {:ok, %{authentications: []}} = Identity.get_user(user.id)
    end

    test "deletes authentication without users", %{user: user = %{authentications: [auth]}} do
      Identity.remove_user_authentication(user, auth)

      refute Repo.get(Authentication, auth.id)
    end

    test "keeps authentication for other users", %{
      user: user = %{authentications: [auth]},
      other_user: other_user = %{authentications: [other_auth]}
    } do
      create!(UserAuthentication, user_id: other_user.id, authentication_id: auth.id)

      Identity.remove_user_authentication(user, auth)

      assert_nested(
        {:ok, %{authentications: [%{id: other_auth.id}, %{id: auth.id}]}},
        Identity.get_user(other_user.id)
      )
    end

    test "keeps authentication with other users", %{
      user: user = %{authentications: [auth]},
      other_user: other_user
    } do
      create!(UserAuthentication, user_id: other_user.id, authentication_id: auth.id)

      Identity.remove_user_authentication(user, auth)

      assert Repo.get(Authentication, auth.id)
    end
  end
end
