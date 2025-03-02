defmodule OrgChat.UsersTenantTest do
  use OrgChat.DataCase, async: false
  alias Ecto.Adapters.SQL.Sandbox
  alias OrgChat.Users
  alias OrgChat.Users.User
  alias OrgChat.Repo

  @tenant "app"

  setup do
    setup_tenant()
    :ok
  end

  defp setup_tenant do
    drop_tenants = fn ->
      Triplex.drop(@tenant, Repo)
    end

    Sandbox.mode(Repo, :auto)

    drop_tenants.()
    on_exit(drop_tenants)

    Triplex.create(@tenant, Repo)
    Triplex.migrate(@tenant, Repo)
  end

  def user_fixture(attrs \\ %{}, tenant \\ @tenant) do
    valid_attrs = %{
      "email" => "user#{System.unique_integer([:positive])}@example.com",
      "password" => "Secret123!",
      "first_name" => "Test",
      "last_name" => "User",
      "role" => "user",
      "properties" => %{}
    }

    merged_attrs = Map.merge(valid_attrs, attrs)
    {:ok, user} = Users.create_user(merged_attrs, tenant)
    user
  end

  describe "list_users/1" do
    test "повертає список користувачів для заданої компанії" do
      user = user_fixture(%{}, @tenant)
      users = Users.list_users(@tenant)
      assert user in users
    end
  end

  describe "get_user!/2" do
    test "повертає користувача за uuid для заданої компанії" do
      user = user_fixture(%{}, @tenant)
      fetched = Users.get_user!(user.uuid, @tenant)
      assert fetched.uuid == user.uuid
    end
  end

  describe "get_user_by_email/2" do
    test "повертає користувача за email для заданої компанії" do
      user = user_fixture(%{}, @tenant)
      fetched = Users.get_user_by_email(user.email, @tenant)
      assert fetched.email == user.email
    end
  end

  describe "create_user/2" do
    test "створює користувача з валідними даними" do
      valid_attrs = %{
        "email" => "newuser@example.com",
        "password" => "Secret123!",
        "first_name" => "New",
        "last_name" => "User",
        "role" => "user",
        "properties" => %{"foo" => "bar"}
      }

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs, @tenant)
      assert user.email == "newuser@example.com"
      assert is_binary(user.password_hash)
    end

    test "повертає помилку при створенні користувача з невалідними даними" do
      invalid_attrs = %{"email" => nil, "password" => nil}
      assert {:error, %Ecto.Changeset{}} = Users.create_user(invalid_attrs, @tenant)
    end
  end

  describe "update_user/3" do
    test "оновлює користувача з валідними даними" do
      user = user_fixture(%{}, @tenant)
      update_attrs = %{"first_name" => "Updated"}
      assert {:ok, %User{} = updated_user} = Users.update_user(user, update_attrs, @tenant)
      assert updated_user.first_name == "Updated"
    end

    test "повертає помилку при оновленні користувача з невалідними даними" do
      user = user_fixture(%{}, @tenant)
      invalid_attrs = %{"email" => nil}
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, invalid_attrs, @tenant)
    end
  end

  describe "delete_user/2" do
    test "видаляє користувача для заданої компанії" do
      user = user_fixture(%{}, @tenant)
      assert {:ok, %User{}} = Users.delete_user(user, @tenant)

      assert_raise Ecto.NoResultsError, fn ->
        Users.get_user!(user.uuid, @tenant)
      end
    end
  end

  describe "change_user/2" do
    test "повертає changeset" do
      user = user_fixture(%{}, @tenant)
      changeset = Users.change_user(user, %{}, @tenant)
      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "authenticate_user/3" do
    test "повертає користувача з валідними даними" do
      password = "Secret123!"
      user = user_fixture(%{"password" => password}, @tenant)
      assert {:ok, auth_user} = Users.authenticate_user(user.email, password, @tenant)
      assert auth_user.uuid == user.uuid
    end

    test "повертає помилку при невірному паролі" do
      user = user_fixture(%{}, @tenant)

      assert {:error, :invalid_password} =
               Users.authenticate_user(user.email, "wrongpass", @tenant)
    end

    test "повертає помилку, якщо користувача не існує" do
      assert {:error, :user_not_found} =
               Users.authenticate_user("nonexistent@example.com", "Secret123!", @tenant)
    end
  end
end
