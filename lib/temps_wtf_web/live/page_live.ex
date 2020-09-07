defmodule TempsWTFWeb.PageLive do
  use TempsWTFWeb, :live_view
  alias TempsWTF.Weather

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, stations: [], state: nil)}
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

  def handle_event("lookup_station", %{"station" => station_id}, socket) do
    {:noreply, socket}
  end

  defp states do
    ["CA", "NY"]
  end

  defp options_for(stations) do
    stations
    |> Enum.map(&{&1.en_name, &1.id})
  end
end
