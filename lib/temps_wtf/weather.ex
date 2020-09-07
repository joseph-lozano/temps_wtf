defmodule TempsWTF.Weather do
  alias TempsWTF.Weather.Station
  alias TempsWTF.Repo
  import Ecto.Query, only: [from: 1, from: 2]

  def get_record_highs(station_id) do
    IO.inspect(station_id)
  end

  def count_stations do
    Repo.aggregate(from(s in Station), :count)
  end

  def stations_by_country_and_region(country, region) do
    Repo.all(
      from s in Station,
        where: [country: ^country, region: ^region],
        order_by: :en_name
    )
  end
end
