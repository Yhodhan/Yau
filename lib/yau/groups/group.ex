defmodule Yau.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :people, :integer
    field :travelling, :boolean, default: :false

    has_many :journeys, Yau.Journeys.Journey

    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:people, :travelling])
    |> validate_required([:people])
    |> validate_number(:people, min: 1)
  end

  def changeset_status(group, attrs) do
    group
    |> cast(attrs, [:travelling])
    |> validate_required([:travelling])
  end
end
