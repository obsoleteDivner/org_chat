defmodule OrgChat.Companies do
  alias OrgChat.Repo
  alias OrgChat.Companies.Company

  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def get_company!(uuid), do: Repo.get!(Company, uuid)
  def get_company_by_name(name), do: Repo.get_by(Company, name: name)

  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  def list_companies do
    Repo.all(Company)
  end
end
