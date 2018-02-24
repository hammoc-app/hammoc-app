defmodule Hammoc.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls, primary_key: false) do
      add :url, :varchar, primary_key: true

      # auto-creates an index "urls_auto_index_urls_link_id_fkey"
      add :link_id, references(:links, on_delete: :nothing, type: :binary_id)
    end
  end
end
