defmodule Hammoc.ScraperTest do
  use Hammoc.DataCase

  alias Hammoc.Scraper

  describe "links" do
    alias Hammoc.Scraper.Link

    @valid_attrs %{excerpt: "some excerpt", html: "some html", keywords: [], main_url: "some main_url", title: "some title"}
    @update_attrs %{excerpt: "some updated excerpt", html: "some updated html", keywords: [], main_url: "some updated main_url", title: "some updated title"}
    @invalid_attrs %{excerpt: nil, html: nil, keywords: nil, main_url: nil, title: nil}

    def link_fixture(attrs \\ %{}) do
      {:ok, link} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Scraper.create_link()

      link
    end

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert Scraper.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Scraper.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link" do
      assert {:ok, %Link{} = link} = Scraper.create_link(@valid_attrs)
      assert link.excerpt == "some excerpt"
      assert link.html == "some html"
      assert link.keywords == []
      assert link.main_url == "some main_url"
      assert link.title == "some title"
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scraper.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      assert {:ok, link} = Scraper.update_link(link, @update_attrs)
      assert %Link{} = link
      assert link.excerpt == "some updated excerpt"
      assert link.html == "some updated html"
      assert link.keywords == []
      assert link.main_url == "some updated main_url"
      assert link.title == "some updated title"
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Scraper.update_link(link, @invalid_attrs)
      assert link == Scraper.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Scraper.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Scraper.change_link(link)
    end
  end

  describe "urls" do
    alias Hammoc.Scraper.Url

    @valid_attrs %{url: "some url"}
    @update_attrs %{url: "some updated url"}
    @invalid_attrs %{url: nil}

    def url_fixture(attrs \\ %{}) do
      {:ok, url} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Scraper.create_url()

      url
    end

    test "list_urls/0 returns all urls" do
      url = url_fixture()
      assert Scraper.list_urls() == [url]
    end

    test "get_url!/1 returns the url with given id" do
      url = url_fixture()
      assert Scraper.get_url!(url.id) == url
    end

    test "create_url/1 with valid data creates a url" do
      assert {:ok, %Url{} = url} = Scraper.create_url(@valid_attrs)
      assert url.url == "some url"
    end

    test "create_url/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scraper.create_url(@invalid_attrs)
    end

    test "update_url/2 with valid data updates the url" do
      url = url_fixture()
      assert {:ok, url} = Scraper.update_url(url, @update_attrs)
      assert %Url{} = url
      assert url.url == "some updated url"
    end

    test "update_url/2 with invalid data returns error changeset" do
      url = url_fixture()
      assert {:error, %Ecto.Changeset{}} = Scraper.update_url(url, @invalid_attrs)
      assert url == Scraper.get_url!(url.id)
    end

    test "delete_url/1 deletes the url" do
      url = url_fixture()
      assert {:ok, %Url{}} = Scraper.delete_url(url)
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_url!(url.id) end
    end

    test "change_url/1 returns a url changeset" do
      url = url_fixture()
      assert %Ecto.Changeset{} = Scraper.change_url(url)
    end
  end
end
