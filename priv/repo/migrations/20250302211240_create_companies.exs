defmodule CorporateChat.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false, unique: true
      add :full_name, :string
      add :company_avatar, :string
      add :locale, :string, default: "en"

      timestamps()
    end

    create unique_index(:companies, [:name])
  end
end
