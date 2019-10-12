defmodule HammocWeb.DashboardLive do
  @moduledoc "A dashboard for your likes and bookmarks powered LiveView"

  use Phoenix.LiveView

  alias HammocWeb.Router.Helpers, as: Routes
  alias Hammoc.Retriever.Status
  alias Hammoc.Search.Facets

  @search Application.get_env(:hammoc, Hammoc.Search)[:module]

  def render(assigns) do
    Phoenix.View.render(HammocWeb.PageView, "dashboard.html",
      user: assigns.user,
      top_hashtags: assigns.top_hashtags,
      top_profiles: assigns.top_profiles,
      facets: assigns.facets,
      autocomplete: assigns.autocomplete,
      conn: assigns.socket,
      retrieval: assigns.retrieval,
      paginator: assigns.paginator
    )
  end

  def mount(_session, socket) do
    send(self(), :subscribe_retrieval_progress)

    user = %{
      screen_name: "sasajuric",
      name: "Saša Jurić",
      profile_image_url:
        "http://pbs.twimg.com/profile_images/485776583542575104/PvpyGtOc_normal.jpeg"
    }

    new_socket =
      socket
      |> assign(:user, user)
      |> assign(:top_hashtags, [])
      |> assign(:top_profiles, [])
      |> assign(:facets, %Facets{})
      |> assign(:autocomplete, nil)
      |> assign(:retrieval, %Status{})
      |> update_tweets()

    {:ok, new_socket}
  end

  def handle_params(params, _uri, socket) do
    new_socket =
      socket
      |> assign(:facets, Facets.from_params(params))
      |> update_tweets()
      |> update_top_hashtags()
      |> update_top_profiles()

    {:noreply, new_socket}
  end

  def handle_event("search-and-autocomplete", params, socket) do
    new_socket = search(socket, params, params["q"])

    {:noreply, new_socket}
  end

  def handle_event("search", params, socket) do
    new_socket = search(socket, params, nil)

    {:noreply, new_socket}
  end

  defp search(socket, form_params, autocomplete) do
    url_params = form_params |> Facets.from_params() |> Facets.to_url_params()
    path = Routes.live_path(socket, __MODULE__, url_params)

    socket
    |> update_autocomplete(autocomplete)
    |> live_redirect(to: path)
  end

  def handle_info(:subscribe_retrieval_progress, socket) do
    Hammoc.Retriever.subscribe()

    {:noreply, socket}
  end

  def handle_info({:retrieval_progress, retrieval_info}, socket) do
    new_socket =
      socket
      |> assign(:retrieval, retrieval_info)
      |> update_tweets()
      |> update_top_hashtags()
      |> update_top_profiles()

    {:noreply, new_socket}
  end

  defp update_tweets(socket) do
    {:ok, paginator} = @search.query(socket.assigns.facets)

    assign(socket, paginator: paginator)
  end

  defp update_top_hashtags(socket) do
    {:ok, top_hashtags} = @search.top_hashtags(socket.assigns.facets)

    assign(socket, top_hashtags: top_hashtags)
  end

  defp update_top_profiles(socket) do
    {:ok, top_profiles} = @search.top_profiles(socket.assigns.facets)

    assign(socket, top_profiles: top_profiles)
  end

  defp update_autocomplete(socket, query) do
    {:ok, suggestions} = @search.autocomplete(query)

    assign(socket, autocomplete: suggestions)
  end
end
