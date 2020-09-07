import Ecto.Query, only: [from: 1, from: 2]
alias TempsWTF.Meteostat
alias TempsWTF.Repo
alias TempsWTF.Weather
alias TempsWTF.Weather.{Station, StationData}
alias TempsWTF.WeatherServer
alias NimbleCSV.RFC4180, as: CSV

states =
  Repo.all(from s in Station, where: [country: "US"], select: [:region])
  |> Enum.map(& &1.region)
  |> Enum.reject(&is_nil(&1))
  |> Enum.uniq()
  |> Enum.sort()
