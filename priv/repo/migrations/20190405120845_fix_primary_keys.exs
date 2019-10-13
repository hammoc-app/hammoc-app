defmodule Hammoc.Repo.Migrations.FixPrimaryKeys do
  use Ecto.Migration

  def up do
    # re-create users
    drop table(:users)

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :binary
      add :email_hash, :binary
      add :newsletter, :boolean
      add :weekly_digest, :boolean
      add :started, :boolean, null: false, default: false

      timestamps()
    end

    create index(:users, [:email_hash])
    create index(:users, [:newsletter])

    # re-create authentications
    drop table(:authentications)

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
    # re-create users
    drop table(:users)

    create table(:users) do
      add :email, :binary
      add :email_hash, :binary
      add :newsletter, :boolean
      add :weekly_digest, :boolean
      add :started, :boolean, null: false, default: false

      timestamps()
    end

    create index(:users, [:email_hash])
    create index(:users, [:newsletter])

    # re-create authentications
    drop table(:authentications)

    create table(:authentications) do
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
end
