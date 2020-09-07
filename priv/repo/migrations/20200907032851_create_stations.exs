defmodule TempsWTF.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations) do
      add :country, :string
      add :elevation, :integer
      add :latitude, :float
      add :longitude, :float
      add :en_name, :string
      add :region, :string
      add :timezone, :string

      timestamps()
    end

  end
end
