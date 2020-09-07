defmodule TempsWTFWeb.PageLive do
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
       station_name: nil,
       in_progress: false
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

    {:noreply, assign(socket, stations: stations, state: state)}
  end

  def handle_event("get_stations", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("lookup_station", %{"station" => %{"id" => station_id}}, socket) do
    {in_progress, {flash, flash_msg}, highs} =
      case Weather.get_record_highs(station_id) do
        :in_progress ->
          {true, {:info, "Getting Data for #{station_id}"}, []}

        {:error, reason} ->
          {false, {:error, reason}, []}

        highs ->
          {false, {:info, "Done!"}, highs}
      end

    socket = clear_flash(socket) |> put_flash(flash, flash_msg)

    {:noreply,
     assign(socket,
       in_progress: in_progress,
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
        :in_progress ->
          raise "???"

        {:error, reason} ->
          assign(socket, in_progress: false) |> clear_flash() |> put_flash(:error, reason)

        data ->
          assign(socket, highs: data, in_progress: false) |> clear_flash()
      end

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

  defp to_fahrenheit(celsius) do
    celsius = Decimal.new("#{celsius}")
    conversion = Decimal.new("1.8")

    fahrenheit =
      Decimal.mult(celsius, conversion)
      |> Decimal.add(Decimal.new(32))
      |> Decimal.round(1)

    "#{fahrenheit}°F "
  end

  defp to_iso8601(%Date{} = date) do
    Date.to_iso8601(date)
  end

  defp to_iso8601(string) when is_binary(string) do
    string
  end
end
