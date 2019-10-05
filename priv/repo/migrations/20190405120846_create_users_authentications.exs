defmodule Hammoc.Repo.Migrations.CreateUsersAuthentications do
  use Ecto.Migration

  def up do
    create table(:users_authentications, primary_key: false) do
      add :user_id,
          references(:users, on_delete: :nothing, type: :binary_id),
          primary_key: true

      add :authentication_id,
          references(:authentications, on_delete: :nothing, type: :binary_id),
          primary_key: true

      timestamps()
    end

    create index(:users_authentications, [:authentication_id])
  end

  def down do
    drop table(:users_authentications)
  end
end
