import Ecto.Query, only: [from: 1, from: 2]
alias TempsWTF.Repo
alias TempsWTF.Weather
alias TempsWTF.Weather.Station

states =
  Repo.all(from s in Station, where: [country: "US"], select: [:region])
  |> Enum.map(& &1.region)
  |> Enum.reject(&is_nil(&1))
  |> Enum.uniq()
  |> Enum.sort()
