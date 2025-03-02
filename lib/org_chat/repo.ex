defmodule OrgChat.Repo do
  use Ecto.Repo,
    otp_app: :org_chat,
    adapter: Ecto.Adapters.Postgres
end
