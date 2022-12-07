defmodule VoltWeb.ItemControllerTest do
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
  @login_data %{email: "lastrestaurant@mail.com", password: "12345", Role: "Restaurant"}


  describe "Menus of restaurant" do
    test "redirect to menus page of restaurant after login", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, "/restaurant/#{conn.assigns.current_user.id}/menu")
      assert html_response(conn, 200) =~ "There are not any items in your menu yet!"
    end
  end

  #US_ID -> 3.4
  describe "Create menu" do
    test "redirect to menus page of restaurant after login", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      user_id = conn.assigns.current_user.id

      query = from m in Menu, where: m.restaurant_id == ^user_id, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})
      conn = get(conn, "/restaurant/#{conn.assigns.current_user.id}/menu")
      assert html_response(conn, 200) =~ "Added Item!"
    end

    test "render error when inserted data is invalid ", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      user_id = conn.assigns.current_user.id

      query = from m in Menu, where: m.restaurant_id == ^user_id, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)

      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => nil, "description" => nil, "category" => "pasta", "price" => 12, "menu_id" => menuId}})
      conn = get(conn, "/restaurant/#{conn.assigns.current_user.id}/menu")
      assert html_response(conn, 200) =~ "Oops! Something went wrong!"
    end

    test "check if registred data inserted into DB", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      user_id = conn.assigns.current_user.id

      query = from m in Menu, where: m.restaurant_id == ^user_id, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)
      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})
      conn = get(conn, "/restaurant/#{conn.assigns.current_user.id}/menu")

      query_name = from m in Item, where: m.name == "Fettucini Alfredo", select: m.name
      menu_name = Volt.Repo.all(query_name)

      assert length(menu_name) > 0
      assert html_response(conn, 200) =~ "Added Item!"
    end

    test "edit and update menu", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      user_id = conn.assigns.current_user.id

      query = from m in Menu, where: m.restaurant_id == ^user_id, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)
      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italin dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})

      query2 = from i in Item, where: i.menu_id == ^menuId and i.name == "Fettucini Alfredo", select: i.id
      itemId = Volt.Repo.all(query2) |> Enum.at(0)

      conn = post(conn, Routes.restaurant_path(conn, :update_item,itemId), %{"item" => %{"name" => "Fettucini ", "description" => "Famous Italin Meal", "category" => "Pasta", "price" => 20}})
      conn = get(conn, "/restaurant/#{conn.assigns.current_user.id}/menu")
      assert html_response(conn, 200) =~ "Successfully updated the item info"
    end

    test "check if data is updated in DB", %{conn: conn} do
      conn = post(conn, Routes.restaurant_path(conn, :create), restaurant: @restaurant_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)

      user_id = conn.assigns.current_user.id

      query = from m in Menu, where: m.restaurant_id == ^user_id, select: m.id
      menuId = Volt.Repo.all(query) |> Enum.at(0)
      conn = post(conn, Routes.item_path(conn, :create, conn.assigns.current_user.id),  %{"item" => %{"name" => "Fettucini Alfredo", "description" => "Famous Italian dish", "category" => "pasta", "price" => 12, "menu_id" => menuId}})

      query2 = from i in Item, where: i.menu_id == ^menuId and i.name == "Fettucini Alfredo", select: i.id
      itemId = Volt.Repo.all(query2) |> Enum.at(0)

      conn = post(conn, Routes.restaurant_path(conn, :update_item,itemId), %{"item" => %{"name" => "Fettucini ", "description" => "Famous Italian Meal", "category" => "Pasta", "price" => 20}})
      conn = get(conn, "/restaurant/#{conn.assigns.current_user.id}/menu")

      query3 = from i in Item, where: i.menu_id == ^menuId and  i.name == "Fettucini" and i.description == "Famous Italian Meal" and i.category == "Pasta" and i.price == ^20, select: i
      # result = Volt.Repo.all(query3)
      # assert length(result) > 0
    end

  end


end
