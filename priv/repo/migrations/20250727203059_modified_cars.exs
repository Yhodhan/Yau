defmodule Yau.Repo.Migrations.ModifiedCars do
  use Ecto.Migration

  def change do
    alter table(:cars) do
      # true for travelling, false for not
      add :status, :boolean
    end
  end
end
