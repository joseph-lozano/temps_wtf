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
       yearly: [],
       station_id: nil,
       station_name: nil,
       records: []
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

    {:noreply, assign(socket, stations: stations, state: state, yearly: [])}
  end

  def handle_event("get_stations", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("lookup_station", %{"station" => %{"id" => station_id}}, socket) do
    socket = clear_flash(socket)

    case Weather.get_yearly_records(station_id) do
      {:error, reason} ->
        socket =
          assign(socket,
            stations: Weather.stations_by_country_and_region("US", socket.assigns.state),
            yearly: [],
            station_id: station_id,
            station_name: station_name(socket, station_id),
            records: []
          )
          |> put_flash(:error, reason)

        {:noreply, socket}

      yearly ->
        socket =
          assign(socket,
            yearly: yearly,
            station_id: station_id,
            station_name: station_name(socket, station_id),
            records: Weather.get_record_highs_and_lows(yearly)
          )
          |> push_event("chart", %{data: encode(yearly)})

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(msg, socket) do
    Logger.warn("UNHANDLED MSG: #{inspect(msg)}")
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

  def class_for({_, {high, _}, {low, _}}, %{record_highs: highs, record_lows: lows}) do
    record_high = high in highs
    record_low = low in lows

    cond do
      record_high and record_low -> "record-both"
      record_high -> "record-high"
      record_low -> "record-low"
      true -> ""
    end
  end

  def to_fahrenheit(nil), do: ""

  def to_fahrenheit(celsius) do
    celsius = Decimal.new("#{celsius}")
    conversion = Decimal.new("1.8")

    Decimal.mult(celsius, conversion)
    |> Decimal.add(Decimal.new(32))
    |> Decimal.round(1)
  end

  defp encode(records) do
    Enum.reduce(records, %{labels: [], data: [[], []]}, fn {date, {_high_date, high_degrees_c},
                                                            {_low_date, low_degrees_c}},
                                                           acc ->
      high_degrees_f = high_degrees_c |> to_fahrenheit() |> Decimal.to_float()
      low_degrees_f = low_degrees_c |> to_fahrenheit() |> Decimal.to_float()

      acc
      |> update_in([:labels], &(&1 ++ [date]))
      |> update_in([:data], fn [highs, lows] ->
        [highs ++ [high_degrees_f], lows ++ [low_degrees_f]]
      end)
    end)
  end
end
