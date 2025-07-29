defmodule Yau.Vehicles do
  import Ecto.Query, warn: false
  alias Yau.Journeys.Journey
  alias Yau.Journeys
  alias Yau.Repo
  alias Yau.Vehicles.Car

  use GenServer

  def all(), do: Repo.all(Car)

  def register(cars) do
    # remove previous data
    register_cars(cars)
    :ok
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

  # ---------------
  #  GenServer API
  # ---------------

  def start_link(initial_list \\ []),
    do: GenServer.start_link(__MODULE__, initial_list, name: __MODULE__)

  def register_cars(cars), do: GenServer.cast(__MODULE__, {:register, cars})

  # ---------------------
  #  Genserver functions
  # ---------------------
  #
  @impl true
  def init(initial_list) do
    {:ok, initial_list}
  end

  @impl true
  def handle_cast({:register, cars}, state) do
    unless Journeys.active_travels?() do
      Repo.delete_all(Car)
      Repo.delete_all(Journey)

      cars
      |> Enum.each(fn car -> create_car(car) end)
    else
      register_cars(cars)
    end

    {:noreply, state}
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
