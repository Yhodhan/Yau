defmodule YauWeb.GroupsController do
  use YauWeb, :controller

  alias Yau.Groups

  def all(conn, _params) do
    groups =
      Groups.all()
      |> Enum.map(fn car -> Map.take(car, [:group_id, :people, :travelling]) end)

    conn
    |> put_status(:ok)
    |> json(%{groups: groups})
  end

  def register_group(conn, %{"group_id" => id, "people" => people}) do
    case Groups.register_group(%{"group_id" => id, "people" => people}) do
      {:ok, group} ->
        conn
        |> put_status(:created)
        |> json(%{id: group.group_id, capacity: group.people})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{erros: changeset.errors})
    end
  end
end
