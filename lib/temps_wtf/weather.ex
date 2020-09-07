defmodule TempsWTF.Weather do
  alias TempsWTF.Weather.Station
  alias TempsWTF.Repo
  import Ecto.Query, only: [from: 1]

  def count_stations do
    Repo.aggregate(from(s in Station), :count)
  end
end
