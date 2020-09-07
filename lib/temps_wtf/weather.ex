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
    case maybe_update_station(station_id) do
      {:ok, _} ->
        station_data_by_station_id(station_id)
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

  def maybe_update_station(station_id) do
    station = get_station(station_id)
    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()

    cond do
      is_nil(station) ->
        {:error, :no_station}

      Date.compare(station.updated_at, today) == :lt ->
        update_station(station)

      true ->
        {:ok, :already_up_to_date}
    end
  end

  def update_station(station) do
    case Meteostat.get_data(station.id) do
      {:ok, station_stats} ->
        init_multi =
          Ecto.Multi.new()
          |> Ecto.Multi.update("touch-station", Station.touch(station))

        Enum.reduce(station_stats, init_multi, fn stats, multi ->
          cs = StationData.changeset(%StationData{}, stats)
          Ecto.Multi.insert(multi, "#{station.id}_#{stats.date}", cs)
        end)
        |> Repo.transaction()

      error ->
        error
    end
  end

  def count_stations do
    Repo.aggregate(from(s in Station), :count)
  end

  def stations_by_country_and_region(country, region) do
    Repo.all(
      from s in Station,
        where: [country: ^country, region: ^region],
        order_by: :en_name
    )
  end
end
