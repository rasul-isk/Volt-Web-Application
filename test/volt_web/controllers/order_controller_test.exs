defmodule VoltWeb.OrderControllerTest do
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

  @restaurant_data %{email: "rest@mail.com", crypted_password: "12345", name: "Ali", address: "Lubja 9, 50303, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "vegan"}
  @restaurant_login_data %{email: "rest@mail.com", password: "12345", Role: "Restaurant"}
  @valid_data %{name: "Customer", email: "newcustomer@gmail.com", crypted_password: "mypassword", dateofbirth: ~D[2002-11-08], address: "Narva mnt 14, 51009, Tartu", cardnumber: "4169741304422112", balance: 300}
  @login_data %{email: "newcustomer@gmail.com", password: "mypassword", Role: "Customer"}
  # @order_data %{order_id: 1, item_id: 1, quantity: 3, status: "Ordered"}

  #US_ID -> 1.8
  describe "my orders" do
    test "render success message and redirect to order history page if signed user's order exist in DB", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      rest_id = Volt.Repo.all(query) |> Enum.at(0)
      user_id = conn.assigns.current_user.id

      conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "19:00", "open_time" => "10:00"}})
      conn = get(conn, Routes.page_path(conn, :index))

      query = from o in Order, where: o.customer_id == ^user_id, select: o
      result = Volt.Repo.all(query)

      assert length(result) > 0
    end

    test "render errors if there is not any orders yet", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      user_id = conn.assigns.current_user.id
      query = from o in Order, where: o.customer_id == ^user_id, select: o
      result = Volt.Repo.all(query)

      assert length(result) == 0
    end
  end

  describe "create orders" do
    test "enter your address and redirects to menu page", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      id = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.public_restaurant_path(conn, :process, id), %{"session" => %{"input_value" => "Narva mnt 14, 51009, Tartu", "restaurant_id" => id}})
      conn = get(conn, Routes.public_restaurant_path(conn, :index, id, chosen_address: "Narva mnt 14, 51009, Tartu"))
      assert html_response(conn, 200) =~ "Total"
    end


    #US_ID -> 5.2
    test "Make an order", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @restaurant_login_data)

      userID = conn.assigns.current_user.id
      query = from m in Menu, where: m.restaurant_id == ^userID, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})


      conn = delete(conn, Routes.session_path(conn, :delete))
      conn = get(conn, Routes.session_path(conn, :new))
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      rest_id = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.public_restaurant_path(conn, :process, rest_id), %{"session" => %{"input_value" => "Narva mnt 14, 51009, Tartu", "restaurant_id" => rest_id}})
      conn = get(conn, Routes.public_restaurant_path(conn, :index, rest_id, chosen_address: "Narva mnt 14, 51009, Tartu"))
      user_id = conn.assigns.current_user.id

      conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "19:00", "open_time" => "10:00"}})


    end

    #US_ID -> 5.10
    test "Check balance of customer after ordering", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
      rest_id = Volt.Repo.all(query) |> Enum.at(0)
      user_id = conn.assigns.current_user.id

      query_balance_before = from c in Customer, where: c.id == ^conn.assigns.current_user.id, select: c.balance
      balance_before = Volt.Repo.all(query_balance_before) |> Enum.at(0)

      conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "05:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "23:00", "open_time" => "01:00"}})
      conn = get(conn, Routes.page_path(conn, :index))

      query_balance_after = from c in Customer, where: c.id == ^conn.assigns.current_user.id, select: c.balance
      balance_after = Volt.Repo.all(query_balance_after) |> Enum.at(0)

      assert balance_before == (balance_after + 51.9)
  end

  #US_ID -> 5.11
  test "Check the price of an order consists of the sum of the items ordered and the delivery fee", %{conn: conn} do
    conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
    conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
    conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

    query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
    rest_id = Volt.Repo.all(query) |> Enum.at(0)
    user_id = conn.assigns.current_user.id

    query_balance_before = from c in Customer, where: c.id == ^conn.assigns.current_user.id, select: c.balance
    balance_before = Volt.Repo.all(query_balance_before) |> Enum.at(0)

    conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "05:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "23:00", "open_time" => "01:00"}})
    conn = get(conn, Routes.page_path(conn, :index))

    query_balance_after = from c in Customer, where: c.id == ^conn.assigns.current_user.id, select: c.balance
    balance_after = Volt.Repo.all(query_balance_after) |> Enum.at(0)

    assert (balance_before - balance_after) == 51.900000000000006
end

  #US_ID -> 5.7
  test "Order in a scheduled time", %{conn: conn} do
    conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
    conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
    conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

    query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
    rest_id = Volt.Repo.all(query) |> Enum.at(0)
    user_id = conn.assigns.current_user.id

    conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "pending", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "pending", "restaurantPreperationTime" => "no-time", "deliveryTime" => "no-time", "orderTimeMade" => "04:23", "isScheduled" => true, "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "23:00", "open_time" => "01:00"}})
    conn = get(conn, Routes.page_path(conn, :index))
    assert html_response(conn, 200) =~ "Order created succesfully. Money withdrawed from card balance."
  end



end
end
