defmodule OrgChat.Users do

  import Ecto.Query, warn: false
  alias OrgChat.Repo
  alias OrgChat.Users.User

  def list_users(company) when is_binary(company) do
    Repo.all(User, prefix: Triplex.to_prefix(company))
  end

  def get_user!(uuid, company) when is_binary(company) do
    Repo.get!(User, uuid, prefix: Triplex.to_prefix(company))
  end

  def get_user_by_email(email, company) when is_binary(email) and is_binary(company) do
    Repo.get_by(User, [email: email], prefix: Triplex.to_prefix(company))
  end

  def create_user(attrs, company) when is_binary(company) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(company))
  end

  def update_user(%User{} = user, attrs, company) when is_binary(company) do
    user
    |> User.changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(company))
  end

  def delete_user(%User{} = user, company) when is_binary(company) do
    Repo.delete(user, prefix: Triplex.to_prefix(company))
  end

  def change_user(%User{} = user, attrs \\ %{}, company) when is_binary(company) do
    User.changeset(user, attrs)
  end

  def authenticate_user(email, password, company)
      when is_binary(email) and is_binary(password) and is_binary(company) do
    user = Repo.get_by(User, [email: email], prefix: Triplex.to_prefix(company))

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :invalid_password}

      true ->
        {:error, :user_not_found}
    end
  end
end
