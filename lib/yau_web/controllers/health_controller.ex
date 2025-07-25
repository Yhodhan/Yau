defmodule YauWeb.HealthController do
  use YauWeb, :controller

  def status(conn, _params) do
    conn
    |> put_status(:ok)
    |> json("OK")
  end
end
