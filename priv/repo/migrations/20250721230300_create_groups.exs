defmodule Yau.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :people, :integer

      timestamps()
    end
  end
end
