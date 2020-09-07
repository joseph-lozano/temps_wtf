defmodule TempsWTF.Repo.Migrations.CreateStationData do
  use Ecto.Migration

  def change do
    create table(:station_data) do
      add(:date, :date)
      add(:temp_avg, :float)
      add(:temp_min, :float)
      add(:temp_max, :float)
      add(:percipitation, :float)
      add(:snow, :integer)
      add(:wind_dir, :float)
      add(:wind_speed, :float)
      add(:wind_gust, :float)
      add(:pressure, :float)
      add(:sunshine_minutes, :float)
      add(:station_id, references(:stations, type: :string, on_delete: :nothing))

      timestamps()
    end

    create(index(:station_data, [:station_id]))
  end
end
