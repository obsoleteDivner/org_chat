defmodule OrgChat.CompaniesTest do
  use OrgChat.DataCase, async: true

  alias OrgChat.Companies
  alias OrgChat.Companies.Company

  @valid_attrs %{name: "CoolTech", company_avatar: "logo.png", locale: "uk"}
  @invalid_attrs %{name: nil}

  test "creates a company with valid attributes" do
    assert {:ok, %Company{name: "CoolTech"}} = Companies.create_company(@valid_attrs)
  end

  test "fails to create a company without a name" do
    assert {:error, changeset} = Companies.create_company(@invalid_attrs)
    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end

  test "retrieves a company by name" do
    {:ok, company} = Companies.create_company(@valid_attrs)
    assert Companies.get_company_by_name("CoolTech") == company
  end

  test "retrieves a company by ID" do
    {:ok, company} = Companies.create_company(@valid_attrs)
    assert Companies.get_company!(company.uuid) == company
  end

  test "updates a company successfully" do
    {:ok, company} = Companies.create_company(@valid_attrs)
    assert {:ok, %Company{company_avatar: "new_logo.png"}} =
             Companies.update_company(company, %{company_avatar: "new_logo.png"})
  end

  test "deletes a company" do
    {:ok, company} = Companies.create_company(@valid_attrs)
    assert {:ok, _} = Companies.delete_company(company)
    assert Companies.get_company_by_name("CoolTech") == nil
  end
end
