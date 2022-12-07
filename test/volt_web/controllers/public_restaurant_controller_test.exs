defmodule VoltWeb.PublicRestaurantControllerTest do
  use VoltWeb.ConnCase

  alias Volt.Items.Item
  alias Volt.Accounts
  alias Volt.Accounts.Customer
  alias Volt.Accounts.Courier
  alias Volt.Accounts.Restaurant
  alias Volt.Orders.Order
  alias Volt.OrderItems.OrderItem
  alias Volt.Menus.Menu
  alias Volt.Repo
  alias Volt.Items
  import Ecto.Query, only: [from: 2]
  alias Volt.Geolocation

  @restaurant_data %{email: "lastrestaurant@mail.com", crypted_password: "12345", name: "Ali", address: "Narva mnt 14, 51009, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "vegan"}
  @valid_data %{name: "Customer", email: "lastcustomer@gmail.com", crypted_password: "mypassword", dateofbirth: ~D[2002-11-08], address: "Lubja 9, 50303, Tartu", cardnumber: "4169741304422112", balance: 300}
  @login_data %{email: "lastcustomer@gmail.com", password: "mypassword", Role: "Customer"}


  describe "restaurants list" do
    test "redirect to restaurants page after login", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, "/restaurants")
      assert html_response(conn, 200) =~ "SHOW RESTAURANTS ON MAP"
    end
  end

  describe "valid address" do
    test "redirect to order menu page if custmer's address is valid", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      query = from r in Restaurant, where: r.email == "lastrestaurant@mail.com", select: r.id
      id = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.public_restaurant_path(conn, :process, id), %{"session" => %{"input_value" => "Raatuse 32, 51002, Tartu", "restaurant_id" => id}})
      conn = get(conn, Routes.public_restaurant_path(conn, :index, id, chosen_address: "Raatuse 32, 51002, Tartu"))
      assert html_response(conn, 200) =~ "Total"
    end

    test "redirect to index page if custmer's address is invalid", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      query = from r in Restaurant, where: r.email == "lastrestaurant@mail.com", select: r.id
      id = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.public_restaurant_path(conn, :process, id), %{"session" => %{"input_value" => "Raatuse 51002, Tartu", "restaurant_id" => id}})
      conn = get(conn, Routes.public_restaurant_path(conn, :addressIndex, id))
      assert html_response(conn, 200) =~ "Enter address"
    end
  end


end
