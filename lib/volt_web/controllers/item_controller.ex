defmodule VoltWeb.ItemController do
  use VoltWeb, :controller

  alias Volt.Repo
  alias Volt.Menus
  alias Volt.Menus.Menu
  alias Volt.Items.Item
  alias Volt.Items
  alias Volt.Accounts.Restaurant

  def index(conn, %{"id" => id}) do
    menu = Repo.get_by!(Menu, id: id) |> Repo.preload([:items])
    render conn, "index.html", menu: menu
  end

  def new(conn, %{"id" => id}) do
    menu = Repo.get_by!(Menu, id: id) |> Repo.preload([:items])
    render conn, "new.html", menu: menu
  end

  def create(conn, %{"item" => item_params}) do
    menu_id = item_params["menu_id"]
    menu = Repo.get_by!(Menu, id: menu_id)
    restaurant = Repo.get_by!(Restaurant, id: menu.restaurant_id)
      case Menus.add_item(menu_id, item_params) do
      {:ok, _comment} ->
        menuChangeset = Menu.changeset(menu, %{"numberOfItems" => menu.numberOfItems + 1})
        Repo.update(menuChangeset)
          conn
          |> put_flash(:info, "Added Item!")
          |> redirect(to: Routes.restaurant_path(conn, :menuIndex, restaurant))
      {:error, _error} ->
          conn
          |> put_flash(:error, "Oops! Something went wrong!")
          |> redirect(to: Routes.restaurant_path(conn, :menuIndex, restaurant))
    end
  end
end
