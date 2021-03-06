defmodule TempsWTF.LoadStations do
  require Logger
  alias TempsWTF.Repo
  alias TempsWTF.Weather
  alias TempsWTF.Weather.Station

  def load() do
    stations_map_list =
      File.read!("priv/stations.json")
      |> Jason.decode!(keys: :atoms)

    if length(stations_map_list) == Weather.count_stations() do
      require Logger
      Logger.info("No stations to add")
    else
      _load(stations_map_list)
    end
  end

  def _load(station_list) do
    init_multi = Ecto.Multi.new()
    epoch_time = DateTime.from_unix!(1) |> DateTime.to_naive()

    Enum.reduce(station_list, init_multi, fn station, multi ->
      %{
        id: id,
        country: country,
        elevation: elevation,
        name: %{en: en_name},
        latitude: latitude,
        longitude: longitude,
        region: region,
        timezone: timezone
      } = station

      attrs = %{
        id: id,
        country: country,
        elevation: elevation,
        en_name: en_name,
        latitude: latitude,
        longitude: longitude,
        region: region,
        timezone: timezone
      }

      cs =
        Station.changeset(%Station{}, attrs)
        |> Ecto.Changeset.force_change(:inserted_at, epoch_time)
        |> Ecto.Changeset.force_change(:updated_at, epoch_time)

      Logger.info("Inserting Station: #{id}")
      Ecto.Multi.insert(multi, id, cs)
    end)
    |> Repo.transaction(timeout: 120_000)
  end
end
