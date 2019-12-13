defmodule Weaver.Twitter.User do
  defstruct contributors_enabled: nil,
            created_at: nil,
            default_profile: nil,
            default_profile_image: nil,
            description: nil,
            entities: nil,
            favourites_count: nil,
            follow_request_sent: nil,
            followers_count: nil,
            following: nil,
            friends_count: nil,
            geo_enabled: nil,
            id: nil,
            id_str: nil,
            is_translation_enabled: nil,
            is_translator: nil,
            lang: nil,
            listed_count: nil,
            location: nil,
            name: nil,
            notifications: nil,
            profile_background_color: nil,
            profile_background_image_url: nil,
            profile_background_image_url_https: nil,
            profile_background_tile: nil,
            profile_banner_url: nil,
            profile_image_url: nil,
            profile_image_url_https: nil,
            profile_link_color: nil,
            profile_sidebar_border_color: nil,
            profile_sidebar_fill_color: nil,
            profile_text_color: nil,
            profile_use_background_image: nil,
            protected: nil,
            screen_name: nil,
            show_all_inline_media: nil,
            status: nil,
            statuses_count: nil,
            time_zone: nil,
            url: nil,
            utc_offset: nil,
            verified: nil,
            withheld_in_countries: nil,
            withheld_scope: nil,
            email: nil

  @type t :: %__MODULE__{}

  def execute(_ctx, obj, "id", _args) do
    {:ok, obj.id}
  end

  def execute(_ctx, _obj, "screenName", _args) do
    {:ok, "arnodirlam"}
  end

  def execute(_ctx, %{"id" => id}, "favorites", _args) do
    tweets =
      favorites(id)
      |> Enum.map(fn t -> {:ok, struct(Weaver.Twitter.Tweet, t)} end)

    {:ok, tweets}
  end

  defp favorites(_id) do
    []
  end
end
