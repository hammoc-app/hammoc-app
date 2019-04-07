defmodule Hammoc.Repo.Migrations.CreateAuthentications do
  use Ecto.Migration

  def up do
    create table(:authentications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :uid, :binary
      add :uid_hash, :binary
      add :access_token, :binary
      add :access_token_secret, :binary
      add :name, :binary
      add :first_name, :binary
      add :last_name, :binary
      add :nickname, :binary
      add :image_url, :binary

      timestamps()
    end

    create index(:authentications, [:provider, :uid_hash], unique: true)
  end

  def down do
    drop table(:authentications)
  end
end
