defmodule TempsWTF.Weather.Station do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "stations" do
    field :country, :string
    field :elevation, :integer
    field :en_name, :string
    field :latitude, :float
    field :longitude, :float
    field :region, :string
    field :timezone, :string
    field :no_data, :boolean

    timestamps()
  end

  def touch(station) do
    change(station, %{updated_at: NaiveDateTime.local_now()})
  end

  def no_data(station) do
    change(station, %{no_data: true})
  end

  @doc false
  def changeset(station, attrs) do
    station
    |> cast(attrs, [
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
      :country,
      :elevation,
      :id,
      :latitude,
      :longitude,
      :en_name
    ])
  end
end
