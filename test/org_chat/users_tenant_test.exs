defmodule OrgChat.UsersTenantTest do
  use OrgChat.DataCase, async: false
  import OrgChat.UserFixtures  

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

  describe "list_users/1" do
    test "returns a list of users for a given company" do
      user = user_fixture(%{}, @tenant)
      users = Users.list_users(@tenant)
      assert user in users
    end
  end

  describe "get_user!/2" do
    test "returns the user by uuid for a given company" do
      user = user_fixture(%{}, @tenant)
      fetched = Users.get_user!(user.uuid, @tenant)
      assert fetched.uuid == user.uuid
    end
  end

  describe "get_user_by_email/2" do
    test "returns the user by email for a given company" do
      user = user_fixture(%{}, @tenant)
      fetched = Users.get_user_by_email(user.email, @tenant)
      assert fetched.email == user.email
    end
  end

  describe "create_user/2" do
    test "creates a user with valid data" do
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

    test "returns an error when creating a user with invalid data" do
      invalid_attrs = %{"email" => nil, "password" => nil}
      assert {:error, %Ecto.Changeset{}} = Users.create_user(invalid_attrs, @tenant)
    end
  end

  describe "update_user/3" do
    test "updates a user with valid data" do
      user = user_fixture(%{}, @tenant)
      update_attrs = %{"first_name" => "Updated"}
      assert {:ok, %User{} = updated_user} = Users.update_user(user, update_attrs, @tenant)
      assert updated_user.first_name == "Updated"
    end

    test "returns an error when updating a user with invalid data" do
      user = user_fixture(%{}, @tenant)
      invalid_attrs = %{"email" => nil}
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, invalid_attrs, @tenant)
    end
  end

  describe "delete_user/2" do
    test "deletes a user for a given company" do
      user = user_fixture(%{}, @tenant)
      assert {:ok, %User{}} = Users.delete_user(user, @tenant)

      assert_raise Ecto.NoResultsError, fn ->
        Users.get_user!(user.uuid, @tenant)
      end
    end
  end

  describe "change_user/2" do
    test "returns a changeset" do
      user = user_fixture(%{}, @tenant)
      changeset = Users.change_user(user, %{}, @tenant)
      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "authenticate_user/3" do
    test "returns the user with valid credentials" do
      password = "Secret123!"
      user = user_fixture(%{"password" => password}, @tenant)
      assert {:ok, auth_user} = Users.authenticate_user(user.email, password, @tenant)
      assert auth_user.uuid == user.uuid
    end

    test "returns an error when the password is incorrect" do
      user = user_fixture(%{}, @tenant)

      assert {:error, :invalid_password} =
               Users.authenticate_user(user.email, "wrongpass", @tenant)
    end

    test "returns an error when the user does not exist" do
      assert {:error, :user_not_found} =
               Users.authenticate_user("nonexistent@example.com", "Secret123!", @tenant)
    end
  end
end
