defmodule TempsWTFWeb.PageLive do
  use TempsWTFWeb, :live_view
  alias TempsWTF.Weather

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, stations: [], state: nil, highs: [], station_id: nil, station_name: nil)}
  end

  @impl true
  def handle_event("get_stations", %{"location" => params}, socket) do
    %{"country" => country, "state" => state} = params

    stations =
      if Enum.any?([country, state], &(&1 == "")) do
        []
      else
        Weather.stations_by_country_and_region(country, state)
      end

    {:noreply, assign(socket, stations: stations, state: state)}
  end

  def handle_event("lookup_station", %{"station" => %{"id" => station_id}}, socket) do
    {socket, highs} =
      case IO.inspect(Weather.get_record_highs(station_id)) do
        {:error, reason} -> {put_flash(socket, :error, inspect(reason)), []}
        highs -> {socket, highs}
      end

    {:noreply,
     assign(socket,
       highs: highs,
       station_id: station_id,
       station_name: station_name(socket, station_id)
     )}
  end

  defp station_name(socket, station_id) do
    stations = socket.assigns.stations

    Enum.find(stations, &(&1.id == station_id))
    |> Map.get(:en_name)
  end

  defp states do
    [
      "AK",
      "AL",
      "AR",
      "AS",
      "AZ",
      "CA",
      "CO",
      "CT",
      "DC",
      "DE",
      "FL",
      "GA",
      "HI",
      "IA",
      "ID",
      "IL",
      "IN",
      "KS",
      "KY",
      "LA",
      "MA",
      "MD",
      "ME",
      "MI",
      "MN",
      "MO",
      "MS",
      "MT",
      "NC",
      "ND",
      "NE",
      "NH",
      "NJ",
      "NM",
      "NV",
      "NY",
      "OH",
      "OK",
      "OR",
      "PA",
      "PR",
      "RI",
      "SC",
      "SD",
      "TN",
      "TX",
      "UT",
      "VA",
      "VI",
      "VT",
      "WA",
      "WI",
      "WV",
      "WY"
    ]
  end

  defp options_for(stations) do
    stations
    |> Enum.map(&{&1.en_name, &1.id})
  end
end
