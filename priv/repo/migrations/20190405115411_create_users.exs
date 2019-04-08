defmodule Hammoc.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :email, :binary
      add :email_hash, :binary
      add :newsletter, :boolean
      add :weekly_digest, :boolean

      timestamps()
    end

    create index(:users, [:email_hash])
    create index(:users, [:newsletter])
  end

  def down do
    drop table(:users)
  end
end
