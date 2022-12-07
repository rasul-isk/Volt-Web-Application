defmodule VoltWeb.RestaurantControllerTest do
  use VoltWeb.ConnCase

  alias Volt.Accounts.Restaurant
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
  alias Ecto.{Changeset, Multi}
  alias Volt.Carts.Cart

  @invalid_data %{email: "ali@mail.ru", crypted_password: "12345", name: "Ali", address: "Lubja 9, 50305, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: nil, tags: nil}
  @valid_data %{email: "ali@mail.ru", crypted_password: "12345", name: "Ali", address: "Raatuse 32, 51002, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "vegan"}
  @existing_data %{email: "ali@mail.ru", crypted_password: "12345", name: "Ali", address: "Raatuse 32, 51002, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "fast-food"}
  @update_data %{email: "veli@mail.ru", crypted_password: "123e45", name: "Veli", address: "Raatuse 32, 51002, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "vegan"}
  @login_data %{email: "ali@mail.ru", password: "12345", Role: "Restaurant"}

  @restaurant_data %{email: "rest@mail.com", crypted_password: "12345", name: "Ali", address: "Lubja 9, 50303, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "vegan"}
  @restaurant_login_data %{email: "rest@mail.com", password: "12345", Role: "Restaurant"}
  @customer_data %{name: "Customer", email: "newcustomer@gmail.com", crypted_password: "mypassword", dateofbirth: ~D[2002-11-08], address: "Narva mnt 14, 51009, Tartu", cardnumber: "4169741304422112", balance: 300}
  @customer_login_data %{email: "newcustomer@gmail.com", password: "mypassword", Role: "Customer"}

  describe "new restaurant" do
    test "redirect to restaurant registration page", %{conn: conn} do
      conn = get(conn, Routes.restaurant_path(conn, :new))
      assert html_response(conn, 200) =~ "Restaurant"
    end
  end

  # US_ID -> 1.3
  describe "create restaurant" do
    test "redirects to login when data is valid", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @valid_data)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "Restaurant and your menu have been successfully created."
    end

    test "renders an error when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @invalid_data)
      conn = get(conn, Routes.restaurant_path(conn, :new))
      assert html_response(conn, 200) =~ "Restaurant Name"
    end

    test "renders errors when existing data wants to register", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @valid_data)
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @existing_data)
      assert redirected_to(conn) == Routes.restaurant_path(conn, :new)
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "Restaurant registration has failed. Entered email exists on system!"
    end

    test "check if registred data inserted into DB", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @valid_data)
      query = from c in Restaurant, where: c.email == "ali@mail.ru", select: c
      available_restaurant = Volt.Repo.all(query)
      conn = get(conn, Routes.session_path(conn, :new))
      assert length(available_restaurant) > 0
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  describe "restaurant login" do
    test "redirect to home page if credentials are correct", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, Routes.page_path(conn, :index)) # Go to home page
      assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
  end
end

describe "edit restaurant info" do
  test "redirects to restaurant info edit page", %{conn: conn} do
    conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @valid_data)
    conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
    conn = get(conn, Routes.page_path(conn, :index)) # Go to home page
    assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
    conn = get(conn, "/restaurant/edit/#{conn.assigns.current_user.id}")
    assert html_response(conn, 200) =~ "Update Restaurant Info"
  end
end


describe "restaurant orders list" do
  #US_ID -> 1.7
    test "restaurant order history", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @restaurant_login_data)
      conn = get(conn, Routes.restaurant_path(conn, :orders_history))
      assert html_response(conn, 200) =~ "Total Revenue"
    end


    #US_ID -> 3.1
    test "list of pending orders", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @customer_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @customer_login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      rest_id = Volt.Repo.all(query) |> Enum.at(0)
      user_id = conn.assigns.current_user.id

      conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "19:00", "open_time" => "10:00"}})

      conn = delete(conn, Routes.session_path(conn, :delete))
      conn = get(conn, Routes.session_path(conn, :new))
      conn = post(conn, Routes.session_path(conn, :create), session: @restaurant_login_data)

      query2 = from o in Order, where: o.restaurant_id == ^rest_id and o.initialStatus == "pending", select: o
      pendingOrders = Volt.Repo.all(query2)

      assert length(pendingOrders) > 0
      conn = get(conn, Routes.restaurant_path(conn, :ordersIndex))
      assert html_response(conn, 200) =~ "Ongoing Orders List"
    end

    #US_ID -> 3.2
    test "list of in process orders", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @customer_data)
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @restaurant_login_data)

      userID = conn.assigns.current_user.id
      query = from m in Menu, where: m.restaurant_id == ^userID, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})


      conn = delete(conn, Routes.session_path(conn, :delete))
      conn = get(conn, Routes.session_path(conn, :new))
      conn = post(conn, Routes.session_path(conn, :create), session: @customer_login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      rest_id = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.public_restaurant_path(conn, :process, rest_id), %{"session" => %{"input_value" => "Narva mnt 14, 51009, Tartu", "restaurant_id" => rest_id}})
      conn = get(conn, Routes.public_restaurant_path(conn, :index, rest_id, chosen_address: "Narva mnt 14, 51009, Tartu"))
      user_id = conn.assigns.current_user.id

      conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "19:00", "open_time" => "10:00"}})
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Order created succesfully. Money withdrawed from card balance."
    end
    end

    # US_ID -> 3.3
    test "list of in prepared orders", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @customer_data)
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @restaurant_login_data)

      userID = conn.assigns.current_user.id
      query = from m in Menu, where: m.restaurant_id == ^userID, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})


      conn = delete(conn, Routes.session_path(conn, :delete))
      conn = get(conn, Routes.session_path(conn, :new))
      conn = post(conn, Routes.session_path(conn, :create), session: @customer_login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      rest_id = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.public_restaurant_path(conn, :process, rest_id), %{"session" => %{"input_value" => "Narva mnt 14, 51009, Tartu", "restaurant_id" => rest_id}})
      conn = get(conn, Routes.public_restaurant_path(conn, :index, rest_id, chosen_address: "Narva mnt 14, 51009, Tartu"))
      user_id = conn.assigns.current_user.id

      conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "19:00", "open_time" => "10:00"}})
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Order created succesfully. Money withdrawed from card balance."
    end
  end
