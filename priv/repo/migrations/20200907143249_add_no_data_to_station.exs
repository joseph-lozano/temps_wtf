defmodule TempsWTF.Repo.Migrations.AddNoDataToStation do
  use Ecto.Migration

  def change do
    alter table("stations") do
      add(:no_data, :boolean)
    end
  end
end
