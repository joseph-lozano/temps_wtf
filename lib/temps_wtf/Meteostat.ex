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
        date: date |> Date.from_iso8601!(),
        temp_avg: nil_if_empty(tavg, :float),
        temp_min: nil_if_empty(tmin, :float),
        temp_max: nil_if_empty(tmax, :float),
        percipitation: nil_if_empty(prcp, :float),
        snow: nil_if_empty(snow, :int),
        wind_dir: nil_if_empty(wdir, :float),
        wind_speed: nil_if_empty(wspd, :float),
        wind_gust: nil_if_empty(wpgt, :float),
        pressure: nil_if_empty(pres, :float),
        sun_minutes: nil_if_empty(tsun, :int)
      }
    end)
  end

  defp nil_if_empty("", _), do: nil
  defp nil_if_empty(x, :float), do: String.to_float(x)
  defp nil_if_empty(x, :int), do: String.to_integer(x)
end
