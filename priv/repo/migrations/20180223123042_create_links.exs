defmodule Hammoc.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :main_url, :varchar
      add :title, :varchar
      add :excerpt, :varchar
      add :html, :varchar
      add :keywords, {:array, :string}

      timestamps()
    end

  end
end
