defmodule VoltWeb.SessionControllerTest do
  use VoltWeb.ConnCase


  @valid_data %{name: "Customer", email: "customer@mail.ru", crypted_password: "murad123", dateofbirth: ~D[2002-11-08], address: "Raatuse 32, 51002, Tartu", cardnumber: "4169741304422112", balance: 300}

 # US_ID -> 1.2
  describe "Login page" do
    test "redirect to login page", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  describe "Sign in as a registered user" do
    test "redirect to home page if credentials are correct", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create),  %{"session" => %{"email" => "customer@mail.ru", "password" => "murad123", "Role" => "Customer"}})
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome #{conn.assigns.current_user.email}"
    end

    test "redirect to login page again if credentials are incorrect", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create),  %{"session" => %{"email" => "customesar@mail.ru", "password" => "muradsa123", "Role" => "Restaurant"}})
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

   # US_ID -> 1.2
  describe "Log out" do
    test "redirect to login page again when user log out and check if user logged out", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.session_path(conn, :create),  %{"session" => %{"email" => "customesar@mail.ru", "password" => "muradsa123", "Role" => "Restaurant"}})
      conn = delete(conn, Routes.session_path(conn, :delete))
      assert conn.assigns.current_user == nil
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign in"
    end
  end
end
