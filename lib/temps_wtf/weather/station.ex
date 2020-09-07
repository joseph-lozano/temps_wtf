defmodule TempsWTF.Weather.Station do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stations" do
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
    |> cast(attrs, [:country, :elevation, :id, :latitude, :longitude, :en_name, :region, :timezone])
    |> validate_required([:country, :elevation, :id, :latitude, :longitude, :en_name, :region, :timezone])
  end
end
