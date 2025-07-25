defmodule YauWeb.CarController do
  use YauWeb, :controller

  alias Yau.Vehicles
  # alias Yau.Vehicles.Car

  def all(conn, _params) do
    cars =
      Vehicles.all()
      |> Enum.map(fn car -> Map.take(car, [:car_id, :capacity]) end)

    conn
    |> put_status(:ok)
    |> json(%{cars: cars})
  end

  def register(conn, %{"cars" => cars}) do
    case Vehicles.register_cars(cars) do
      :ok ->
        conn
        |> put_status(:ok)
        |> json("OK")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{erros: changeset.errors})
    end
  end

  def update(conn, %{"car_id" => id, "capacity" => capacity}) do
    case Vehicles.update_car(id, capacity) do
      {:ok, car} ->
        conn
        |> put_status(:ok)
        |> json(%{id: car.car_id, capacity: car.capacity})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{erros: changeset.errors})
    end
  end

  def delete(conn, %{"car_id" => id} = _params) do
    case Vehicles.delete_car(id) do
      {:ok, _} ->
        conn
        |> put_status(:ok)
        |> json(%{id: id, message: "deleted with success"})

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{erros: error})
    end
  end
end
