defmodule TempsWTFWeb.PageLive do
  use TempsWTFWeb, :live_view
  alias TempsWTF.Weather

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, stations: [], state: nil, highs: [])}
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
    highs = Weather.get_record_highs(station_id)
    {:noreply, assign(socket, highs: highs)}
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
