defmodule Yau.Repo.Migrations.CreateCars do
  use Ecto.Migration

  def change do
    create table(:cars) do
      add :car_id, :integer
      add :capacity, :integer

      timestamps()
    end

    create unique_index(:cars, [:car_id])
  end
end
