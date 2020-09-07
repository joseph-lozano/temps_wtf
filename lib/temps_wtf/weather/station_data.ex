defmodule TempsWTF.Weather.StationData do
  alias TempsWTF.Weather.Station

  @doc """
  temp_avg:         The average air temperature in °C
  temp_min:         The minimum air temperature in °C
  temp_max:  	      The maximum air temperature in °C
  percipitaion:  	  The daily precipitation total in mm
  snow:  	          The snow depth in mm
  wind_dir:  	      The average wind direction in degrees (°)
  wind_speed:  	    The average wind speed in km/h
  wind_gust       	The peak wind gust in km/h
  pressure:        	The average sea-level air pressure in hPa
  sunshine_minutes: The daily sunshine total in minutes (m)
  """
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :string
  schema "station_data" do
    field :date, :date
    field :percipitation, :float
    field :pressure, :float
    field :snow, :integer
    field :sunshine_minutes, :integer
    field :temp_avg, :float
    field :temp_max, :float
    field :temp_min, :float
    field :wind_dir, :float
    field :wind_gust, :float
    field :wind_speed, :float
    belongs_to :station, Station

    timestamps()
  end

  @doc false
  def changeset(station_data, attrs) do
    station_data
    |> cast(attrs, [
      :station_id,
      :date,
      :temp_avg,
      :temp_min,
      :temp_max,
      :percipitation,
      :snow,
      :wind_dir,
      :wind_speed,
      :wind_gust,
      :pressure,
      :sunshine_minutes
    ])
    |> validate_required([:station_id, :date])
  end
end
