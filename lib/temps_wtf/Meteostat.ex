defmodule TempsWTF.Meteostat do
  require Logger
  alias NimbleCSV.RFC4180, as: CSV
  @doc "Wrapper around HTTP Poison to decode gzipped files"

  def get_data(station_id) do
    url = "https://bulk.meteostat.net/daily/#{station_id}.csv.gz"

    Logger.info("GET: #{url}")

    case HTTPoison.get(url) do
      {:ok, %{status_code: 404}} ->
        {:error, "No data for station #{station_id}"}

      {:ok, resp} ->
        try do
          data =
            :zlib.gunzip(resp.body)
            |> parse(station_id)

          {:ok, data}
        rescue
          e ->
            {:error, e}
        end

      error ->
        error
    end
  end

  def parse(csv, station_id) do
    CSV.parse_string(csv)
    |> Enum.map(fn [date, tavg, tmin, tmax, prcp, snow, wdir, wspd, wpgt, pres, tsun] ->
      %{
        station_id: station_id,
        date: date,
        temp_avg: nil_if_empty(tavg),
        temp_min: nil_if_empty(tmin),
        temp_max: nil_if_empty(tmax),
        percipitation: nil_if_empty(prcp),
        snow: nil_if_empty(snow),
        wind_dir: nil_if_empty(wdir),
        wind_speed: nil_if_empty(wspd),
        wind_gust: nil_if_empty(wpgt),
        pressure: nil_if_empty(pres),
        sun_minutes: nil_if_empty(tsun)
      }
    end)
  end

  defp nil_if_empty(""), do: nil
  defp nil_if_empty(x), do: x
end
