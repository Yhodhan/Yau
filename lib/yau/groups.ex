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
    case Repo.get(Group, id) do
      nil ->
        {:error, :not_found}

      group ->
        Group.changeset(group, attrs)
        |> Repo.update()
    end
  end

  def delete_group(group = %Group{}), do: Repo.delete(group)

  def delete_group(id) do
    case Repo.get(Group, id) do
      nil ->
        {:error, :not_found}

      group ->
        Repo.delete(group)
    end
  end

  def travelling?(id) do
    group = Repo.get_by!(Group, id)
    group.travelling
  end
end
