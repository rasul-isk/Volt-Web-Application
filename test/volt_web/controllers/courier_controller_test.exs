defmodule VoltWeb.CourierControllerTest do
  use VoltWeb.ConnCase

  alias Volt.Accounts.Courier
  alias Volt.Accounts.Restaurant
  alias Volt.Accounts.Order
  alias Volt.Orders.Order
  alias Volt.Menus.Menu
  import Ecto.Query, only: [from: 2]
  alias Ecto.{Changeset, Multi}
  alias Volt.Carts.Cart
  alias Volt.Geolocation

  @valid_data %{name: "murad", email: "courier@mail.ru", crypted_password: "murad123"}
  @existing_data %{name: "Bravo", email: "courier@mail.com", crypted_password: "32124"}
  @update_courier %{name: "courier", email: "courier@mail.ru", revenue: 0, likes: 0, dislikes: 0, status: "available", role: "Courier", rejectedOrders: ""}
  @login_data %{email: "courier@mail.ru", password: "murad123", Role: "Courier"}

  @restaurant_data %{email: "rest@mail.com", crypted_password: "12345", name: "Ali", address: "Lubja 9, 50303, Tartu", opens_at: "10:43", closes_at: "12:59", description: "Lorem ipsum dolor sit amet", category: "Burger", tags: "vegan"}
  @restaurant_login_data %{email: "rest@mail.com", password: "12345", Role: "Restaurant"}
  @customer_data %{name: "Customer", email: "newcustomer@gmail.com", crypted_password: "mypassword", dateofbirth: ~D[2002-11-08], address: "Narva mnt 14, 51009, Tartu", cardnumber: "4169741304422112", balance: 300}
  @customer_login_data %{email: "newcustomer@gmail.com", password: "mypassword", Role: "Customer"}


  describe "new courier" do
    test "redirect to courier registration page", %{conn: conn} do
      conn = get(conn, Routes.courier_path(conn, :new))
      assert html_response(conn, 200) =~ "Courier Name"
    end
  end

  describe "create courier" do
    test "redirects to login when data is valid", %{conn: conn} do
      conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "Courier created successfully."
    end

    test "redirect courier registration page again when input data is already exist", %{conn: conn} do
      conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
      conn = post(conn, Routes.courier_path(conn, :create), courier: @existing_data)
      conn = get(conn, Routes.courier_path(conn, :new))
      assert html_response(conn, 200) =~"Courier Name"
    end

    test "check if registred data is exist in DB", %{conn: conn} do
      conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
      query = from c in Courier, where: c.email == "courier@mail.ru", select: c
      available_courier = Volt.Repo.all(query)

      conn = get(conn, Routes.session_path(conn, :new))
      assert length(available_courier) > 0
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  describe "courier login" do
    test "redirect to home page if credentials are correct", %{conn: conn} do
      conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, Routes.page_path(conn, :index)) # Go to home page
      assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
  end
end

describe "edit courier info" do
  test "redirects to courier edit page", %{conn: conn} do
    conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
    conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
    conn = get(conn, Routes.page_path(conn, :index)) # Go to home page
    assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
    conn = get(conn, "/courier/edit/#{conn.assigns.current_user.id}")
    assert html_response(conn, 200) =~ "Update Courier Info"
  end
end

describe "Courier availablity" do
  #US_ID -> 4.2
  test "change courier availability and check if it is", %{conn: conn} do
    conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
    conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
    conn = post(conn,  Routes.courier_path(conn, :update, conn.assigns.current_user.id), %{"courier" => %{"name" => "courier", "email" => "courier@mail.ru", "revenue" => 0, "likes" => 0, "dislikes" => 0, "status" => "Available"}})
    conn = get(conn, Routes.courier_profile_path(conn, :index))
    assert html_response(conn, 200) =~ "Tere, #{conn.assigns.current_user.name}!"
  end
end


describe "Available Orders List" do

  #US_ID -> 4.2
  test "courier order history", %{conn: conn} do
    conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
    conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
    conn = get(conn, Routes.courier_path(conn, :orders_index))
    assert html_response(conn, 200) =~ "Total Revenue"
  end

  #US_ID -> 4.2
  # test "see nearby available orders", %{conn: conn} do
  #   conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
  #   conn = post(conn, Routes.customer_path(conn, :create), customer: @customer_data)
  #   conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
  #   conn = post(conn, Routes.session_path(conn, :create), session: @restaurant_login_data)

  #   #create menu
  #   user_id = conn.assigns.current_user.id
  #   query = from m in Menu, where: m.restaurant_id == ^user_id, select: m.id
  #   menuId = Volt.Repo.all(query) |> Enum.at(0)

  #   conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})

  #   #make order
  #   conn = delete(conn, Routes.session_path(conn, :delete))
  #   conn = get(conn, Routes.session_path(conn, :new))
  #   conn = post(conn, Routes.session_path(conn, :create), session: @customer_login_data)

  #   query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
  #   rest_id = Volt.Repo.all(query) |> Enum.at(0)
  #   user_id = conn.assigns.current_user.id

  #   conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "accepted", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "in-process", "restaurantPreperationTime" => "04:00", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "23:00", "open_time" => "00:00"}})

  #   #go to orders page accepted by restaurant
  #   conn = delete(conn, Routes.session_path(conn, :delete))
  #   conn = get(conn, Routes.session_path(conn, :new))
  #   conn = post(conn, Routes.session_path(conn, :create), session: @login_data)


  #   conn = post(conn, Routes.courier_path(conn, :address_selection_process, conn.assigns.current_user.id), %{"session" => %{"input_value" => "Lubja 9, 50303 Tartu, Estonia"}})
  #   conn = get(conn, Routes.courier_path(conn, :available_orders_index, "Lubja 9, 50303 Tartu, Estonia"))
  #   assert html_response(conn, 200) =~ "Available orders nearby"
  # end

  #US_ID -> 4.3
  # test "accept an available order", %{conn: conn} do
  #   conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
  #   conn = post(conn, Routes.customer_path(conn, :create), customer: @customer_data)
  #   conn = post(conn, Routes.session_path(conn, :create), session: @customer_login_data)

  #   query = from r in Restaurant, where: r.email == "rest@mail.com", select: r.id
  #   rest_id = Volt.Repo.all(query) |> Enum.at(0)
  #   user_id = conn.assigns.current_user.id

  #   conn = post(conn, Routes.order_path(conn, :create_order), %{"items" => %{"customer_id" => user_id, "restaurant_id" => rest_id, "courier_id" => 1, "restaurantFee" => "49.26", "deliveryFee" => "2.64", "addressFrom" => "Lubja 9, 50303, Tartu", "addressTo" => "Narva mnt 14, 51009, Tartu", "initialStatus" => "accepted", "isCancelled" => false, "orderOverallStatus" => "submitted", "orderRestaurantStatus" => "in-process", "restaurantPreperationTime" => "04:00", "deliveryTime" => "no-time", "orderTimeMade" => "10:23", "isScheduled" => "false", "rejectMessage" => "noMessage", "item-final-fee" => "51.9", "close_time" => "23:00", "open_time" => "00:00"}})
  #   query2 = from o in Order, where: o.restaurant_id == ^rest_id and o.customer_id == ^user_id, select: o.id
  #   order_id = Volt.Repo.all(query2) |> Enum.at(0)

  #   conn = post(conn, Routes.courier_path(conn, :create), courier: @valid_data)
  #   conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

  #   conn = post(conn, Routes.courier_path(conn, :address_selection_process, conn.assigns.current_user.id), %{"session" => %{"input_value" => "Narva mnt 14, 51009, Tartu"}})
  #   conn = get(conn, Routes.courier_path(conn, :available_orders_index, "Narva mnt 14, 51009, Tartu"))

  #   conn = post(conn, Routes.courier_path(conn, :accept_order, order_id), %{"courier" => %{"courier_id" => conn.assigns.current_user.id}})



  # end

end
end
