defmodule Weaver.Twitter.Tweet do
  defstruct contributors: nil,
            coordinates: nil,
            created_at: nil,
            current_user_retweet: nil,
            display_text_range: nil,
            entities: nil,
            extended_entities: nil,
            extended_tweet: nil,
            favorite_count: nil,
            favorited: nil,
            filter_level: nil,
            full_text: nil,
            geo: nil,
            id: nil,
            id_str: nil,
            in_reply_to_screen_name: nil,
            in_reply_to_status_id: nil,
            in_reply_to_status_id_str: nil,
            in_reply_to_user_id: nil,
            in_reply_to_user_id_str: nil,
            lang: nil,
            place: nil,
            possibly_sensitive: nil,
            quoted_status_id: nil,
            quoted_status_id_str: nil,
            quoted_status: nil,
            scopes: nil,
            retweet_count: nil,
            retweeted: nil,
            retweeted_status: nil,
            source: nil,
            text: nil,
            truncated: nil,
            user: nil,
            withheld_copyright: nil,
            withheld_in_countries: nil,
            withheld_scope: nil

  @type t :: %__MODULE__{}

  def execute(_ctx, obj, "id", _args) do
    {:ok, obj.id}
  end

  def execute(_ctx, _obj, "text", _args) do
    {:ok, "Hello world."}
  end

  def execute(_ctx, _obj, "publishedAt", _args) do
    {:ok, "2019-01-02T13:37:37Z"}
  end
end
