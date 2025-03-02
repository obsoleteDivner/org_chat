defmodule OrgChat.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @derive {Phoenix.Param, key: :uuid}
  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :role, :string
    field :password, :string
    field :password_hash, :string

    field :properties, :map

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :role, :password, :properties])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
