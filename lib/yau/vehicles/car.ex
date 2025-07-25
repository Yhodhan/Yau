defmodule Yau.Vehicles.Car do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cars" do
    field :car_id, :integer
    field :capacity, :integer

    has_many :journeys, Yau.Journeys.Journey

    timestamps()
  end

  def changeset(car, attrs) do
    car
    |> cast(attrs, [:car_id, :capacity])
    |> validate_required([:car_id, :capacity])
    |> unique_constraint(:car_id)
  end
end
