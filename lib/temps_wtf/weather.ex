defmodule TempsWTF.Weather do
  alias TempsWTF.Weather.{Station, StationData}
  alias TempsWTF.Meteostat
  alias TempsWTF.Repo
  import Ecto.Query, only: [from: 1, from: 2]

  def get_station(station_id) do
    Repo.one(
      from s in Station,
        where: s.id == ^station_id
    )
  end

  def get_record_highs(station_id) do
    get_station_stats(station_id)
    |> case do
      {:ok, {:fetched_from_database, data}} ->
        {:ok, data}

      {:ok, {:fetched_from_meteostat, data}} ->
        station_id
        |> get_station()
        |> update_station(data)

        {:ok, data}
    end
    |> case do
      {:ok, data} ->
        data
        |> Enum.reject(&is_nil(&1.temp_max))
        |> Enum.reduce(%{max: nil, dates: []}, fn data, %{max: max, dates: dates} = acc ->
          if gt(data.temp_max, max) do
            %{max: data.temp_max, dates: [{data.date, data.temp_max} | dates]}
          else
            acc
          end
        end)
        |> Map.get(:dates)

      e ->
        e
    end
  end

  def gt(_, nil), do: true
  def gt(a, b), do: a > b

  def station_data_by_station_id(station_id) do
    Repo.all(
      from d in StationData,
        where: d.station_id == ^station_id,
        order_by: d.date
    )
  end

  def update_no_data(station) do
    cs = Station.no_data(station)
    Repo.update!(cs)
  end

  def update_station(station, station_stats) do
    Task.async(fn ->
      init_multi =
        Ecto.Multi.new()
        |> Ecto.Multi.update("touch-station", Station.touch(station))

      Enum.reduce(station_stats, init_multi, fn stats, multi ->
        cs = StationData.changeset(%StationData{}, stats)
        Ecto.Multi.insert(multi, "#{station.id}_#{stats.date}", cs)
      end)
      |> Repo.transaction(timeout: 120_000)
    end)
  end

  def get_station_stats(station_id) do
    case station_data_by_station_id(station_id) do
      [] ->
        case Meteostat.get_data(station_id) do
          {:ok, data} ->
            {:ok, {:fetched_from_meteostat, data}}

          {:error, reason} ->
            {:error, reason}
        end

      data ->
        {:ok, {:fetched_from_database, data}}
    end
  end

  def count_stations do
    Repo.aggregate(from(s in Station), :count)
  end

  def stations_by_country_and_region(country, region) do
    Repo.all(
      from s in Station,
        where: [country: ^country, region: ^region],
        where: is_nil(s.no_data),
        order_by: :en_name
    )
  end
end
