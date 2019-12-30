defmodule Test.Support.Factory do
  @moduledoc "Generate test data, raw or in the database."

  alias Hammoc.Identity.{Authentication, User}

  def create!(type, params \\ []) do
    type
    |> build(params)
    |> type.changeset(%{})
    |> Hammoc.Repo.insert!()
  end

  def build(type, fields_or_count \\ [], fun \\ nil)

  def build(type, count, nil) when is_integer(count) do
    Range.new(0, count - 1)
    |> Enum.map(fn _i -> build(type) end)
  end

  def build(type, count, fun) when is_integer(count) do
    Range.new(0, count - 1)
    |> Enum.map(fn i -> build(type, fun.(i)) end)
  end

  def build(type, fields, _fun) when is_list(fields) do
    struct!(type, fields_for(type, fields))
  end

  def fields_for(type, fields \\ [])

  def fields_for(Authentication, fields) do
    %{
      provider: "twitter",
      uid: Faker.String.base64(),
      access_token: Faker.String.base64(32),
      access_token_secret: Faker.String.base64(32),
      nickname: Faker.Internet.user_name()
    }
    |> Enum.into(fields)
  end

  def fields_for(User, fields) do
    %{
      email: Faker.Internet.email(),
      newsletter: true
    }
    |> Enum.into(fields)
  end

  def fields_for(ExTwitter.Model.User, fields) do
    {id, fields} = Keyword.pop(fields, :id, twitter_id())

    %{
      id: id,
      id_str: Integer.to_string(id),
      screen_name: Faker.Internet.user_name(),
      favourites_count: 0,
      followers_count: 0,
      friends_count: 0,
      listed_count: 0,
      statuses_count: 0
    }
    |> Enum.into(fields)
  end

  def fields_for(ExTwitter.Model.Tweet, fields) do
    {id, fields} = Keyword.pop(fields, :id, twitter_id())

    %{
      id: id,
      id_str: Integer.to_string(id),
      full_text: Faker.Lorem.sentence(),
      user: build(ExTwitter.Model.User),
      created_at: "2019-12-12T13:37:00",
      favorite_count: 0,
      retweet_count: 0
    }
    |> Enum.into(fields)
  end

  def twitter_id() do
    :rand.uniform(1_000_000_000)
  end
end
