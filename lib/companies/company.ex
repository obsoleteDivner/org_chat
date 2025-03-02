defmodule OrgChat.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "companies" do
    field :name, :string
    field :full_name, :string
    field :company_avatar, :string
    field :locale, :string, default: "en"

    timestamps()
  end

  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :full_name, :company_avatar, :locale])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_format(:name, ~r/^[a-zA-Z0-9_\- ]+$/, message: "Invalid company name")
  end
end
