defmodule Yau.VehiclesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Yau.Vehicles` context.
  """

  @doc """
  Generate a car.
  """
  def car_fixture(attrs \\ %{}) do
    {:ok, car} =
      attrs
      |> Enum.into(%{
        capacity: 42,
        id: 42
      })
      |> Yau.Vehicles.create_car()

    car
  end

  @doc """
  Generate a car.
  """
  def car_fixture(attrs \\ %{}) do
    {:ok, car} =
      attrs
      |> Enum.into(%{
        capacity: 42,
        car_id: 42
      })
      |> Yau.Vehicles.create_car()

    car
  end
end
