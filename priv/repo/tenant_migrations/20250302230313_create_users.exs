defmodule OrgChat.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :email, :string, null: false
      add :first_name, :string
      add :last_name, :string
      add :role, :string
      add :password, :string, null: false
      add :password_hash, :string, null: false
      add :properties, :map

      timestamps()
    end
    create unique_index(:users, [:uuid])
    create unique_index(:users, [:email])
  end
end
