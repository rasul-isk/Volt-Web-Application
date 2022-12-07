defmodule VoltWeb.SessionController do
  use VoltWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => crypted_password}}) do
    case VoltWeb.Authentication.check_credentials(conn, email, crypted_password, repo: Volt.Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome #{email}")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, reason, conn} ->
        conn
        |> put_flash(:error, reason)
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> clear_session()
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/login")
  end

end
