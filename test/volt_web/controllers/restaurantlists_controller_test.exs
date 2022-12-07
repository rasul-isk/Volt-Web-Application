defmodule VoltWeb.RestaurantlistsControllerTest do
  use VoltWeb.ConnCase
  alias Volt.Accounts
  alias Volt.Accounts.Restaurant
  alias Volt.Accounts.Menu
  alias Volt.Geolocation
  alias Volt.Repo
  alias Volt.Menus.Menu

  @valid_data %{name: "Customer", email: "customer@mail.ru", crypted_password: "murad123", dateofbirth: ~D[2002-11-08], address: "Raatuse 32, 51002, Tartu", cardnumber: "4169741304422112", balance: 300}
  @login_data %{email: "customer@mail.ru", password: "murad123", Role: "Customer"}

  #US_ID -> 2.1
  describe "Restaurants list" do
    test "redirect to restaurants page if credentials are correct", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, Routes.restaurantlists_path(conn, :index))
      assert html_response(conn, 200) =~ "SHOW RESTAURANTS ON MAP"
    end

  end

end
