defmodule VoltWeb.PublicRestaurantController do
  use VoltWeb, :controller

  alias Erl2ex.Pipeline.Parse
  alias Volt.Items.Item
  alias Volt.Accounts
  alias Volt.Accounts.Customer
  alias Volt.Accounts.Restaurant
  alias Volt.Menus.Menu
  alias Volt.Repo
  alias Volt.Items

  def index(conn, params) do #%{"restName" => id}
    id = params["restName"]
    chosen_address = params["chosen_address"]

    restaurant = Repo.get_by!(Restaurant, id: id) |> Repo.preload([:menus, :reviews])
    menu = Repo.get_by!(Menu, id: restaurant.menus.id) |> Repo.preload([:items])

    items_ID = menu.items |> Enum.map(fn x -> x.id end) |> Enum.join(",")
    courier_fee = Volt.Geolocation.calculate_fee(restaurant.address, chosen_address)
    render(conn, "index.html", restaurant: restaurant, menu: menu, items_ID: items_ID, courier_fee: courier_fee, chosen_address: chosen_address)
    # render(conn, "index.html", restaurant_id: id, chosen_address: address)
  end

  def process(conn, _) do
    params = conn.params["session"]
    id = params["restaurant_id"]
    address = params["input_value"]

    if(address == "" || !Volt.Geolocation.address_valid_soft(address)) do
      conn
      |> put_flash(:error, "Error Occured! Check your entered address.")
      |> redirect(to: Routes.public_restaurant_path(conn, :addressIndex, id))
    else
      conn
      |> redirect(to: Routes.public_restaurant_path(conn,:index, id, chosen_address: address))
    end
  end

  def addressIndex(conn, %{"restName" => id}) do
    customer_id = conn.assigns.current_user.id
    customer = Repo.get_by!(Customer, id: conn.assigns.current_user.id) |> Repo.preload([:orders])
    no_pending_orders = customer.orders|> Enum.filter(fn x -> (x.initialStatus != "rejected" && x.isCancelled == false && x.orderOverallStatus != "delivered") end) |> Enum.empty?()
    if(no_pending_orders) do
      render(conn, "address_selection.html", restaurant_id: id)
    else
      conn
      |> put_flash(:error, "You have an existing order. Please, finish it first.")
      |> redirect(to: Routes.restaurantlists_path(conn, :index))
    end
  end

end
