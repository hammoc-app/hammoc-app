defmodule Test.Support.Factory do
  @moduledoc "Generate test data, raw or in the database."

  alias Hammoc.Identity.{Authentication, User}

  def create!(type, params \\ []) do
    type
    |> build(params)
    |> type.changeset(%{})
    |> Hammoc.Repo.insert!()
  end

  def build(type, params \\ %{}) do
    struct!(type, fields_for(type, params))
  end

  def fields_for(type, params) do
    attrs = fields_for(type)

    # merge `params` Keyword list into `attrs` Map
    Enum.reduce(params, attrs, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  def fields_for(Authentication) do
    %{
      provider: "twitter",
      uid: Faker.String.base64(),
      access_token: Faker.String.base64(32),
      access_token_secret: Faker.String.base64(32),
      nickname: Faker.Internet.user_name()
    }
  end

  def fields_for(User) do
    %{
      email: Faker.Internet.email(),
      newsletter: true
    }
  end

  def fields_for(_type), do: %{}
end
