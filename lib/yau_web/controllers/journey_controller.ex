defmodule YauWeb.JourneyController do
  use YauWeb, :controller
  alias Yau.Journeys
  alias Yau.Groups

  def journey(conn, %{"id" => group_id, "people" => people}) do
    case Groups.register_group(%{"group_id" => group_id, "people" => people}) do
      {:ok, _group} ->
        Journeys.request_travel(group_id, people)

        conn
        |> put_status(:created)
        |> json(%{id: group_id, capacity: people})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: changeset.errors})
    end
  end

  def drop_off(conn, %{"id" => group_id}) do
    case Journeys.drop_off(group_id) do
      {:ok, group} ->
        conn
        |> put_status(:created)
        |> json(%{id: group.group_id, capacity: group.people})

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: error})
    end
  end

  def locate(conn, %{"id" => group_id}) do
    case Journeys.locate(group_id) do
      {:ok, :awaiting} ->
        conn
        |> put_status(:no_content)
        |> json("")

      {:ok, car} ->
        conn
        |> put_status(:ok)
        |> json(%{"car_id" => car.car_id, "capacity" => car.capacity})

      {:error, :group_not_found} ->
        conn
        |> put_status(:not_found)
        |> json("ERROR")
    end
  end
end
