defmodule TempsWTFWeb.PageLive do
  require Logger
  use TempsWTFWeb, :live_view
  alias TempsWTF.Weather

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       stations: [],
       state: nil,
       highs: [],
       station_id: nil,
       station_name: nil
     )}
  end

  @impl true
  def handle_event("get_stations", %{"location" => params}, socket) do
    IO.inspect(params)
    %{"country" => country, "state" => state} = params

    stations =
      if Enum.any?([country, state], &(&1 == "")) do
        []
      else
        Weather.stations_by_country_and_region(country, state)
      end

    {:noreply, assign(socket, stations: stations, state: state, highs: [])}
  end

  def handle_event("get_stations", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("lookup_station", %{"station" => %{"id" => station_id}}, socket) do
    socket = clear_flash(socket)

    case Weather.get_record_highs(station_id) do
      {:error, reason} ->
        socket =
          assign(
            socket,
            stations:
              Weather.stations_by_country_and_region(
                "US",
                socket.assigns.state
              ),
            highs: [],
            station_id: station_id,
            station_name: station_name(socket, station_id)
          )
          |> put_flash(:error, reason)

        {:noreply, socket}

      highs ->
        yearly = Weather.get_yearly_highs(station_id)

        socket =
          assign(socket,
            highs: highs,
            station_id: station_id,
            station_name: station_name(socket, station_id)
          )
          |> push_event("chart", %{data: encode(yearly)})

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        {:updated_data, station_id},
        %{assigns: %{station_id: station_id_socket}} = socket
      )
      when station_id == station_id_socket do
    socket =
      case Weather.get_record_highs(station_id) do
        {:error, reason} ->
          socket |> clear_flash() |> put_flash(:error, reason)

        data ->
          assign(socket, highs: data) |> clear_flash()
      end

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    Logger.debug("UNHANDLED MSG: #{inspect(msg)}")
    {:noreply, socket}
  end

  defp station_name(socket, station_id) do
    stations = socket.assigns.stations

    Enum.find(stations, &(&1.id == station_id))
    |> get_in([Access.key(:en_name)])
  end

  defp states do
    [
      {"Alaska", "AK"},
      {"Alabama", "AL"},
      {"Arkansas", "AR"},
      {"American Samoa", "AS"},
      {"Arizona", "AZ"},
      {"California", "CA"},
      {"Colorado", "CO"},
      {"Connecticut", "CT"},
      {"Washington D.C.", "DC"},
      {"Delaware", "DE"},
      {"Florida", "FL"},
      {"Georgia", "GA"},
      {"Hawaii", "HI"},
      {"Iowa", "IA"},
      {"Idaho", "ID"},
      {"Illinois", "IL"},
      {"Indiana", "IN"},
      {"Kansas", "KS"},
      {"Kentucky", "KY"},
      {"Louisiana", "LA"},
      {"Massachusetts", "MA"},
      {"Maryland", "MD"},
      {"Maine", "ME"},
      {"Michigan", "MI"},
      {"Minnesota", "MN"},
      {"Missouri", "MO"},
      {"Mississippi", "MS"},
      {"Montana", "MT"},
      {"North Carolina", "NC"},
      {"North Dakota", "ND"},
      {"Nebraska", "NE"},
      {"New Hampshire", "NH"},
      {"New Jersey", "NJ"},
      {"New Mexico", "NM"},
      {"Nevada", "NV"},
      {"New York", "NY"},
      {"Ohio", "OH"},
      {"Oklahoma", "OK"},
      {"Oregon", "OR"},
      {"Pennslyvania", "PA"},
      {"Puerto Rico", "PR"},
      {"Rhode Island", "RI"},
      {"South Carolina", "SC"},
      {"South Dakota", "SD"},
      {"Tennesee", "TN"},
      {"Texas", "TX"},
      {"Utah", "UT"},
      {"Virginia", "VA"},
      {"Virgin Islands", "VI"},
      {"Vermont", "VT"},
      {"Washington", "WA"},
      {"Wisconsin", "WI"},
      {"West Virginia", "WV"},
      {"Wyoming", "WY"}
    ]
  end

  defp options_for(stations) do
    stations
    |> Enum.map(&{&1.en_name, &1.id})
  end

  def to_fahrenheit(celsius) do
    celsius = Decimal.new("#{celsius}")
    conversion = Decimal.new("1.8")

    Decimal.mult(celsius, conversion)
    |> Decimal.add(Decimal.new(32))
    |> Decimal.round(1)
  end

  defp to_iso8601(%Date{} = date) do
    Date.to_iso8601(date)
  end

  defp encode(highs) do
    Enum.reduce(highs, %{labels: [], data: []}, fn {date, degrees_c}, acc ->
      degrees_f = degrees_c |> to_fahrenheit() |> Decimal.to_float()

      acc
      |> update_in([:labels], &(&1 ++ [to_iso8601(date)]))
      |> update_in([:data], &(&1 ++ [degrees_f]))
    end)
  end
end
