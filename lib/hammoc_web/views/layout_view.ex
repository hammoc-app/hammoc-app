defmodule HammocWeb.LayoutView do
  use HammocWeb, :view

  alias Hammoc.Identity.User

  def user_display_name(user) do
    if auth = user_display_auth(user) do
      auth.name || auth.nickname
    else
      user.email
    end
  end

  def user_display_image_url(user) do
    if auth = user_display_auth(user) do
      auth.image_url
    end
  end

  defp user_display_auth(user) do
    Enum.find(user.authentications, fn auth -> (auth.name || auth.nickname) && auth.image_url end) ||
      Enum.find(user.authentications, fn auth -> auth.name || auth.nickname end)
  end
end
