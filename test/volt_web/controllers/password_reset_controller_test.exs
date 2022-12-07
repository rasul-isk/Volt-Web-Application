defmodule VoltWeb.PasswordResetControllerTest do
  use VoltWeb.ConnCase
  alias Volt.Accounts.{Customer, Courier, Restaurant}
  alias Volt.Repo
  alias Volt.{Email, Mailer, Accounts}
  import Ecto.Query, only: [from: 2]
  alias Ecto.{Changeset, Multi}
  alias Volt.Carts.Cart
  alias Volt.Geolocation
  # import Kernel, except: [to_string: 1]

  @valid_data %{name: "Customer", email: "lastcustomer@gmail.com", crypted_password: "mypassword", dateofbirth: ~D[2002-11-08], address: "Lubja 9, 50303, Tartu", cardnumber: "4169741304422112", balance: 300}


  describe "Reset Password" do
    test "redirect to reset password page", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :new))
    end
  end
  describe "Create new password" do
    test "send reset instruction if there is such user in DB", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.password_reset_path(conn, :create), email: "lastcustomer@gmail.com")
      query1 = from c in Customer, where: c.email == "lastcustomer@gmail.com", select: c
      query2 = from c in Courier, where: c.email == "lastcustomer@gmail.com", select: c
      query3 = from c in Restaurant, where: c.email == "lastcustomer@gmail.com", select: c

      customer_email = Volt.Repo.all(query1)
      courier_email = Volt.Repo.all(query2)
      restaurant_email = Volt.Repo.all(query3)

      assert length(customer_email) > 0 || length(courier_email) > 0 || length(restaurant_email) > 0
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "Email sent with password reset instructions"
    end

    test "display error message if there is not such user in DB", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.password_reset_path(conn, :create), email: "ali@gmail.ru")
      query1 = from c in Customer, where: c.email == "ali@gmail.ru", select: c
      query2 = from c in Courier, where: c.email == "ali@gmail.ru", select: c
      query3 = from c in Restaurant, where: c.email == "ali@gmail.ru", select: c

      customer_email = Volt.Repo.all(query1)
      courier_email = Volt.Repo.all(query2)
      restaurant_email = Volt.Repo.all(query3)

      assert length(customer_email) == 0 && length(courier_email) == 0 && length(restaurant_email) == 0
      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "No email exists"
    end
  end

  describe "Edit password" do
    test "redirect to new password adding page", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.password_reset_path(conn, :create), email: "lastcustomer@gmail.com")
      query =  from c in Customer, where: c.email == "lastcustomer@gmail.com", select: c.password_reset_token
      password_token = to_string(Volt.Repo.all(query))
      conn = get(conn, "/password-reset/#{password_token}/edit")
      assert html_response(conn, 200) =~ "New password"
    end
  end

  describe "Update password" do
    test "update password to the new password", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.password_reset_path(conn, :create), email: "lastcustomer@gmail.com")
      query_id =  from c in Customer, where: c.email == "lastcustomer@gmail.com", select: c.id
      user_id =  Volt.Repo.all(query_id) |> Enum.at(0)

      conn = put(conn, Routes.password_reset_path(conn, :update, user_id), %{"customer"=>%{"crypted_password" => "12345"}})
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Your password has been reset. Sign in below with your new password."
    end

    test "check if password updated in DB", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), customer: @valid_data)
      conn = post(conn, Routes.password_reset_path(conn, :create), email: "lastcustomer@gmail.com")
      query_id =  from c in Customer, where: c.email == "lastcustomer@gmail.com", select: c.id
      query_pass =  from c in Customer, where: c.email == "lastcustomer@gmail.com", select: c.crypted_password
      user_id =  Volt.Repo.all(query_id) |> Enum.at(0)
      old_password = to_string(Volt.Repo.all(query_pass))

      conn = put(conn, Routes.password_reset_path(conn, :update, user_id), %{"customer"=>%{"crypted_password" => "12345"}})
      conn = get(conn, Routes.session_path(conn, :new))

      query = from c in Customer, where: c.email == "eminem@rap.com", select: c.crypted_password
      new_password = to_string(Volt.Repo.all(query))
      assert new_password != old_password
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

end
