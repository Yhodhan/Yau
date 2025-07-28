defmodule Yau.Repo.Migrations.ModifiedGroupsConstrains do
  use Ecto.Migration

  def change do

    create unique_index(:groups, [:group_id])
  end
end
