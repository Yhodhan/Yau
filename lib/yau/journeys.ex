defmodule Yau.Journeys do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Yau.Vehicles.Car
  alias Yau.Groups
  alias Yau.Groups.Group
  alias Yau.Repo
  alias Yau.Journeys.Journey
  alias Yau.Vehicles

  use GenServer

  def all(), do: Repo.all(Journey)

  def request_travel(group_id, people) do
    car =
      Vehicles.all()
      |> Enum.find(fn c -> c.capacity >= people and not c.status end)
      |> IO.inspect(label: "car available")

    if is_nil(car) do
      enqueue(group_id, people)
      Process.send_after(__MODULE__, :check_availability, 1000)
    else
      register_journey(group_id, car)
    end
  end

  def drop_journeys() do
    Repo.delete_all(Journey)
    Repo.delete_all(Group)
  end

  def register_journey(group_id, car) do
    group = Repo.get_by(Group, group_id: group_id)
    attrs = %{"group_id" => group.id, "car_id" => car.id}

    Multi.new()
    |> Multi.insert(:journeys, Journey.changeset(%Journey{}, attrs))
    |> Multi.update(:groups, Group.changeset_status(group, %{travelling: true}))
    |> Multi.update(:cars, Car.changeset_status(car, %{status: true}))
    |> Repo.transaction()
  end

  def active_travels?() do
    q = from(j in Journey, select: 1)
    Repo.exists?(q)
  end

  def drop_off(group_id) do
    group =
      Repo.get_by(Group, group_id: group_id)
      |> Repo.preload(journeys: [:car])

    car =
      group
      |> Map.get(:journeys)
      |> Enum.at(0)
      |> Map.get(:car)

    car
    |> Car.changeset_status(%{status: false})
    |> Repo.update()

    dequeue(group_id)

    # this also deletes the journey
    Groups.delete_group(group)
  end

  def locate(id) do
    group = Repo.get_by(Group, group_id: id)

    journey =
      Repo.get_by(Journey, group_id: group.id)

    unless is_nil(journey) do
      Vehicles.fetch_car_by_journey(journey)
    else
      groups = get_groups()

      awaits = Enum.reduce(groups, false, fn g, acc -> acc or g.group_id == id end)

      if awaits do
        {:ok, :awaiting}
      else
        {:error, :group_not_found}
      end
    end
  end

  # ---------------
  #  GenServer API
  # ---------------

  def start_link(initial_list \\ []),
    do: GenServer.start_link(__MODULE__, initial_list, name: __MODULE__)

  def enqueue(group_id, people), do: GenServer.cast(__MODULE__, {:enqueue, group_id, people})

  def dequeue(group_id), do: GenServer.cast(__MODULE__, {:dequeue, group_id})

  def get_groups(), do: GenServer.call(__MODULE__, :get_groups)

  def health(), do: send(__MODULE__, :health)

  # ---------------------
  #  Genserver functions
  # ---------------------

  @impl true
  def init(initial_list) do
    {:ok, initial_list}
  end

  @impl true
  def handle_cast({:enqueue, group_id, people}, state) do
    new_state =
      [%{group_id: group_id, people: people, inserted_at: DateTime.utc_now()} | state]
      |> Enum.sort_by(fn g -> g.inserted_at end)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:dequeue, group_id}, state) do
    new_state = Enum.reject(state, fn g -> g.group_id == group_id end)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_groups, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:check_availability, state) do
    groups = state

    cars = Vehicles.all()

    new_state = Enum.filter(groups, fn g -> not find_car?(g, cars) end)

    Process.send_after(__MODULE__, :check_availability, 10000)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:health, state) do
    IO.puts("i am alive master")
    IO.inspect(state, label: "the queue list is")

    {:noreply, state}
  end

  # -------------------------
  #     Private functions
  # -------------------------

  defp get_car_by_journey(journey), do: Repo.get(Car, journey.car_id)

  defp find_car?(group, cars) do
    car = Enum.find(cars, fn c -> c.capacity >= group.people and not c.status end)

    case car do
      nil ->
        false

      _ ->
        register_journey(group.group_id, car)
        true
    end
  end
end
