defmodule VoltWeb.CourierProfileController do
  use VoltWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
