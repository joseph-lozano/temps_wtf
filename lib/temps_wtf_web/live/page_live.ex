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

    {socket, highs} =
      case Weather.get_record_highs(station_id) do
        {:error, reason} ->
          {put_flash(socket, :error, reason), []}

        highs ->
          yearly = Weather.get_yearly_highs(station_id)
          {push_event(socket, "chart", %{data: encode(yearly)}), highs}
      end

    {:noreply,
     assign(socket,
       highs: highs,
       station_id: station_id,
       station_name: station_name(socket, station_id)
     )}
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
