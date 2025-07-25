defmodule Yau.Vehicles do
  import Ecto.Query, warn: false
  alias Yau.Journeys.Journey
  alias Yau.Journeys
  alias Yau.Repo
  alias Yau.Vehicles.Car

  def all(), do: Repo.all(Car)

  def register_cars(cars) do
    # remove previous data
    # it should check there is no ongoing journeys
    unless Journeys.active_travels?() do
      Repo.delete_all(Car)
      Repo.delete_all(Journey)

      cars
      |> Enum.each(fn car -> create_car(car) end)
    else
      register_cars(cars)
    end
  end

  def delete_car(id) do
    case fetch_car(id) do
      {:ok, car} ->
        Repo.delete(car)

      {:error, error} ->
        {:error, error}
    end
  end

  def update_car(id, capacity) do
    case fetch_car(id) do
      {:ok, car} ->
        Car.changeset(car, %{"capacity" => capacity})
        |> Repo.update()

      {:error, error} ->
        {:error, error}
    end
  end

  # ------------------
  #  Helper functions
  # ------------------
  defp create_car(attrs) do
    %Car{}
    |> Car.changeset(attrs)
    |> Repo.insert()
  end

  def fetch_car(id) do
    case Repo.get_by(Car, car_id: id) do
      nil ->
        {:error, :car_not_found}

      car ->
        {:ok, car}
    end
  end
end
