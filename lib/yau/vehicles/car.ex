defmodule Yau.Vehicles.Car do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cars" do
    field :car_id, :integer
    field :capacity, :integer
    field :status, :boolean, default: false

    has_many :journeys, Yau.Journeys.Journey

    timestamps()
  end

  def changeset(car, attrs) do
    car
    |> cast(attrs, [:car_id, :capacity, :status])
    |> validate_required([:car_id, :capacity])
    |> unique_constraint(:car_id)
  end

  def changeset_status(car, attrs) do
    car
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
