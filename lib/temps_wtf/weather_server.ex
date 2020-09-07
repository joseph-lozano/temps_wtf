defmodule TempsWTF.WeatherServer do
  require Logger
  @doc "GenServer to asynchronously do long running tasks"
  alias TempsWTF.Weather

  use GenServer

  def find_or_start(station_id, caller) do
    IO.inspect(caller, label: "CALLER")

    case start_link(station_id, caller) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        GenServer.cast(pid, {:subscribe, caller})
        {:ok, pid}

      error ->
        error
    end
  end

  def start_link(station_id, caller) do
    subscribers = MapSet.new([caller])

    GenServer.start_link(
      __MODULE__,
      %{subscribers: subscribers, station_id: station_id, in_progress: false, data: []},
      name: {:global, station_id}
    )
  end

  def get_data(station_id, caller \\ nil) do
    server = {:global, station_id}
    unless is_nil(caller), do: GenServer.cast(server, {:subscribe, caller})
    GenServer.call(server, :get_data)
  end

  @impl true
  def init(opts) do
    {:ok, opts, {:continue, :get_data}}
  end

  @impl true
  def handle_continue(:get_data, state) do
    do_get_data(state.station_id)
    {:noreply, put_in(state.in_progress, true)}
  end

  def handle_continue(:update_subscribers, state) do
    Enum.each(state.subscribers, fn pid ->
      send(pid, {:updated_data, state.station_id})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:subscribe, caller}, state) do
    {:noreply, update_in(state.subscribers, &MapSet.put(&1, caller))}
  end

  @impl true
  def handle_call(:get_data, _from, %{data: data} = state) when data != [] do
    {:reply, data, state}
  end

  def handle_call(:get_data, _from, %{in_progress: true} = state) do
    {:reply, :in_progress, state}
  end

  def handle_call(:get_data, _from, state) do
    IO.inspect(state.data)
    do_get_data(state.station_id)
    {:reply, :in_progress, put_in(state.in_progress, true)}
  end

  @impl true
  def handle_info({_ref, {:max_temps, data}}, state) do
    Logger.info("GOT DATA FOR #{state.station_id}")
    {:noreply, %{state | in_progress: false, data: data}, {:continue, :update_subscribers}}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    {:noreply, state}
  end

  defp do_get_data(station_id) do
    Task.async(fn ->
      {:max_temps, Weather.do_get_record_highs(station_id)}
    end)
  end
end
