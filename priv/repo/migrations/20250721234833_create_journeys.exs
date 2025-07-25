defmodule Yau.Repo.Migrations.CreateJourneys do
  use Ecto.Migration

  def change do
    create table(:journeys) do
      add :car_id, references(:cars, on_delete: :delete_all)
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

    create index(:journeys, [:car_id])
    create index(:journeys, [:group_id])
  end
end
