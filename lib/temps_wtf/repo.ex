defmodule TempsWTF.Repo do
  use Ecto.Repo,
    otp_app: :temps_wtf,
    adapter: Ecto.Adapters.Postgres
end
