defmodule Yau.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :people, :integer
    field :group_id, :integer
    field :travelling, :boolean, default: false

    has_many :journeys, Yau.Journeys.Journey

    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:people, :group_id, :travelling])
    |> validate_required([:people, :group_id])
    |> validate_number(:people, greater_than: 0)
    |> unique_constraint(:group_id)
  end

  def changeset_status(group, attrs) do
    group
    |> cast(attrs, [:travelling])
    |> validate_required([:travelling])
  end
end
