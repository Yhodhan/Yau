defmodule Yau.Groups do
  import Ecto.Query, warn: false
  alias Yau.Repo
  alias Yau.Groups.Group

  def all(), do: Repo.all(Group)

  def register_group(attrs) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  def register_groups(groups) do
    groups
    |> Enum.each(fn g -> register_group(g) end)
  end

  def update_group(%{"group_id" => id} = attrs) do
    case fetch_group(id) do
      {:ok, group} ->
        Group.changeset(group, attrs)
        |> Repo.update()

      {:error, error} ->
        {:error, error}
    end
  end

  def delete_group(id) do
    case fetch_group(id) do
      {:ok, group} ->
        Repo.delete(group)

      {:error, error} ->
        {:error, error}
    end
  end

  def travelling?(id) do
    group = Repo.get_by!(Group, id)
    group.travelling
  end

  # -------------------------
  #     Private functions
  # -------------------------
  defp fetch_group(id) do
    case Repo.get_by(Group, group_id: id) do
      nil ->
        {:error, :group_not_found}

      car ->
        {:ok, car}
    end
  end
end
