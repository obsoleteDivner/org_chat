defmodule OrgChat.UserFixtures do
  alias OrgChat.Users

  def user_fixture(attrs \\ %{}, tenant) do
    valid_attrs = %{
      "email" => "user#{System.unique_integer([:positive])}@example.com",
      "password" => "Secret123!",
      "first_name" => "Test",
      "last_name" => "User",
      "role" => "user",
      "properties" => %{}
    }

    merged_attrs = Map.merge(valid_attrs, attrs)

    case Users.create_user(merged_attrs, tenant) do
      {:ok, user} -> user
      {:error, changeset} -> raise "User fixture creation failed: #{inspect(changeset.errors)}"
    end
  end
end
