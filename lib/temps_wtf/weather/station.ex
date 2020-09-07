defmodule TempsWTF.Weather.Station do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "stations" do
    field :last_updated, :date
    field :country, :string
    field :elevation, :integer
    field :en_name, :string
    field :latitude, :float
    field :longitude, :float
    field :region, :string
    field :timezone, :string

    timestamps()
  end

  @doc false
  def changeset(station, attrs) do
    station
    |> cast(attrs, [
      :last_updated,
      :country,
      :elevation,
      :id,
      :latitude,
      :longitude,
      :en_name,
      :region,
      :timezone
    ])
    |> validate_required([
      :last_updated,
      :country,
      :elevation,
      :id,
      :latitude,
      :longitude,
      :en_name
    ])
  end
end
