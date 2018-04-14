# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Hammoc.Repo.insert!(%Hammoc.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Hammoc.Repo
alias Hammoc.Scraper.{Link, Url}

Ecto.Adapters.SQL.query!(Repo, "DELETE FROM urls;", [])
Ecto.Adapters.SQL.query!(Repo, "DELETE FROM links;", [])

graphql =
  Repo.insert!(%Url{
    url: "http://graphql.org/",
    link: %Link{
      title: "GraphQL | A query language for your API",
      main_url: "http://graphql.org/",
      excerpt: """
      A query language for your API

      GraphQL is a query language for APIs and a runtime for fulfilling those queries with your existing data. GraphQL provides a complete and understandable description of the data in your API, gives clients the power to ask for exactly what they need and nothing more, makes it easier to evolve APIs over time, and enables powerful developer tools.
      """
    }
  })

uuid =
  Repo.insert!(%Url{
    url: "https://www.cockroachlabs.com/docs/stable/uuid.html",
    link: %Link{
      title: "UUID | Cockroach Labs",
      main_url: "https://www.cockroachlabs.com/docs/stable/uuid.html",
      excerpt: """
      The UUID data type stores 128-bit Universal Unique Identifiers.
      """
    }
  })

Ecto.Adapters.SQL.query!(Repo, """
SELECT u0."url", u0."link_id", u0."link_id" FROM "urls" AS u0 WHERE (u0."link_id" = ANY($1)) ORDER BY u0."link_id"
""", [[graphql.link.id, uuid.link.id] |> Enum.map(&UUID.string_to_binary!/1)])
|> IO.inspect