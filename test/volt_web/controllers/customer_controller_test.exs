defmodule VoltWeb.CustomerControllerTest do
  use VoltWeb.ConnCase
  alias Volt.Accounts.Customer
  import Ecto.Query, only: [from: 2]
  alias Ecto.{Changeset, Multi}
  alias Volt.Carts.Cart
  alias Volt.Geolocation
  alias Volt.Accounts.{Customer, Courier, Restaurant}
  alias Volt.Repo
  alias Volt.{Email, Mailer, Accounts}

  @valid_data %{name: "Customer", email: "customer@mail.ru", crypted_password: "murad123", dateofbirth: ~D[2002-11-08], address: "Raatuse 32, 51002, Tartu", cardnumber: "4169741304422112", balance: 300}
  @existing_data %{name: "customer", email: "customer@mail.ru", crypted_password: "murad123", dateofbirth: ~D[1999-11-08], address: "Raatuse 32, 51002, Tartu", cardnumber: "4169741304422112", balance: 300}
  @update_customer %{name: "Murad", email: "customer@mail.ru",  dateofbirth: ~D[2000-11-08], address: "Raatuse 32, 51002, Tartu", cardnumber: "4169741304422112", balance: 300}
  @login_data %{email: "customer@mail.ru", password: "murad123", Role: "Customer"}


  describe "new customer" do
    test "redirect to customer registration page", %{conn: conn} do
      conn = get(conn, Routes.customer_path(conn, :new))
      assert html_response(conn, 200) =~ "Customer Name"
    end
  end

  # US_ID -> 1.1, 1.4
  describe "create customer" do
    test "redirects to login when data is valid", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "You have successfully registered. Please login to place your orders!"
    end

    test "renders errors when existing data wants to registr", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.customer_path(conn, :create), customer: @existing_data)
      assert redirected_to(conn) == Routes.customer_path(conn, :new)
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "Your registration has failed. Entered email exists on system."
    end

    test "check if registred data inserted into DB", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      query = from c in Customer, where: c.email == "customer@mail.ru", select: c
      available_customer = Volt.Repo.all(query)
      conn = get(conn, Routes.session_path(conn, :new))
      assert length(available_customer) > 0
      assert html_response(conn, 200) =~ "Sign in"

    end
  end

  # US_ID -> 1.2
  describe "customer login" do
    test "redirect to home page if credentials are correct", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
    end

    #US_ID -> 1.8
    test "customer order history", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, Routes.customer_path(conn, :orders_index))
      assert = html_response(conn, 200) =~ "Customer Order History"
    end
  end

  describe "edit customer info" do
    test "redirects to customer info edit page", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create), session: @login_data)
      conn = get(conn, Routes.page_path(conn, :index)) # Go to home page
      assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
      conn = get(conn, "/customer/edit/#{conn.assigns.current_user.id}")
      assert html_response(conn, 200) =~ "Update Customer Info"
    end
  end

  end
