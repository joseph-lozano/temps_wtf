import Ecto.Query, only: [from: 1, from: 2]
alias TempsWTF.Meteostat
alias TempsWTF.Repo
alias TempsWTF.Weather
alias TempsWTF.Weather.{Station, StationData}
alias TempsWTF.WeatherServer
alias NimbleCSV.RFC4180, as: CSV

TempsWTF.ReleaseTasks.load_stations()
Logger.configure(truncate: :infinity)
