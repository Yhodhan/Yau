defmodule Yau.Journeys do
  import Ecto.Query, warn: false
  alias Yau.Groups.Group
  alias Yau.Repo
  alias Yau.Journeys.Journey
  alias Yau.Vehicles

  use GenServer

  def all(), do: Repo.all(Journey)

  def register_journey(group_id, car) do
    attrs = %{"group_id" => group_id, "car_id" => car.car_id}

    %Journey{}
    |> Journey.changeset(attrs)
    |> Repo.insert()

    # udpate group status in db
    group = Repo.get_by(Group, group_id: group_id)

    group
    |> Group.changeset_status(%{travelling: true})
    |> Repo.update()
  end

  def request_travel(group_id, people) do
    car =
      Vehicles.all()
      |> Enum.find(fn c -> c.capacity >= people end)

    if is_nil(car) do
      enqueue(group_id, people)
      send(__MODULE__, :check_availability)
    else
      register_journey(group_id, car)
    end
  end

  def active_travels?() do
    q = from(j in Journey, select: 1)
    Repo.exists?(q)
  end

  # ---------------
  #  GenServer API
  # ---------------

  def start_link(initial_list \\ []) do
    GenServer.start_link(__MODULE__, initial_list, name: __MODULE__)
  end

  def enqueue(group_id, people) do
    GenServer.cast(__MODULE__, {:enqueue, group_id, people})
  end

  def denqueue(group_id) do
    GenServer.cast(__MODULE__, {:denqueue, group_id})
  end

  def health() do
    send(__MODULE__, :health)
  end

  # ---------------------
  #  Genserver functions
  # ---------------------

  @impl true
  def init(initial_list) do
    {:ok, initial_list}
  end

  @impl true
  def handle_cast({:enqueue, group_id, people}, state) do
    new_state = [state | %{group_id: group_id, people: people}]

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:denqueue, group_id}, state) do
    new_state = Enum.reject(state, fn g -> g.group_id == group_id end)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:health, state) do
    IO.puts("i am alive master")
    IO.puts("the queue list is: #{state}")

    {:noreply, state}
  end
end
