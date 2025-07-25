defmodule Yau.Repo do
  use Ecto.Repo,
    otp_app: :yau,
    adapter: Ecto.Adapters.Postgres
end
