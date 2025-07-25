defmodule Yau.Journeys.Journey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "journeys" do
    belongs_to :car, Yau.Vehicles.Car
    belongs_to :group, Yau.Groups.Group

    timestamps()
  end

  def changeset(journey, attrs) do
    journey
    |> cast(attrs, [:car_id, :group_id])
    |> foreign_key_constraint(:car_id)
    |> foreign_key_constraint(:group_id)
  end
end
