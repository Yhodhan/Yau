defmodule Yau.Repo.Migrations.ModifiedGroups do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :group_id, :integer
      # true for travelling, false for not
      add :travelling, :boolean
    end
  end
end
