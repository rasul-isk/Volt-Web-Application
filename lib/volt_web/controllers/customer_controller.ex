defmodule VoltWeb.CustomerController do
  use VoltWeb, :controller
  alias String.Chars.DateTime
  alias Volt.Repo
  # alias Volt.Customer
  alias Volt.Accounts.Customer
  alias Volt.Orders.Order
  alias Volt.Reviews.Review

  def new(conn, _params) do
    render conn, "new.html"
  end

  def emailIsUnique(email) do
    repo = Volt.Repo
    noSuchCustomer = is_nil(repo.get_by(Volt.Accounts.Customer, email: email))
    noSuchCourier = is_nil(repo.get_by(Volt.Accounts.Courier, email: email))
    noSuchRestaurant = is_nil(repo.get_by(Volt.Accounts.Restaurant, email: email))

    if(noSuchCustomer && noSuchCourier && noSuchRestaurant) do
      true
    else
      false
    end
  end

  def create(conn, %{"customer" => customer_params}) do
    if(customer_params["address"]!=="") do
      if(emailIsUnique(customer_params["email"])) do
        changeset = Customer.changeset(%Customer{}, customer_params)

        if(Volt.Geolocation.address_valid(customer_params["address"])) do
          case Customer.create(changeset, Volt.Repo) do
            {:ok, _user} ->
              conn
              |> put_flash(:info, "You have successfully registered. Please login to place your orders!")
              |> redirect(to: Routes.session_path(conn, :new))
            {:error, changeset} ->
              conn
              |> put_flash(:info, "Your registration has failed. Please try again!")
              |> render(conn, "new.html", changeset: changeset)
          end
        else
          conn
            |> put_flash(:error, "Your registration has failed: Address doesn't exists or entered in wrong format!")
            |> redirect(to: Routes.customer_path(conn,:new))
        end
      else
        conn
          |> put_flash(:error, "Your registration has failed. Entered email exists on system.")
          |> redirect(to: Routes.customer_path(conn,:new))
      end
    else
        conn
          |> put_flash(:error, "Either enable geolocation or put your address in given field.")
          |> redirect(to: Routes.customer_path(conn,:new))
    end

  end

  def edit(conn, %{"id" => id}) do
    customer = Repo.get!(Customer, id)
    changeset = Customer.changeset(customer, %{})
    render(conn, "edit.html", customer: customer, changeset: changeset)
  end

  def update(conn, customer_params) do
    customer = Repo.get!(Customer, conn.assigns.current_user.id)
    changeset = Customer.changeset(customer, customer_params)

    if(Volt.Geolocation.address_valid(customer_params["address"])) do
      Repo.update(changeset)
      redirect(conn, to: Routes.customer_profile_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Profile hasn't been edited. Address doesn't exists or entered in wrong format!")
      |> redirect(to: Routes.customer_profile_path(conn, :index))
    end
  end

  def orders_index(conn, _params) do
    customer = Repo.get_by!(Customer, id: conn.assigns.current_user.id) |> Repo.preload([orders: [:restaurants, :couriers, :reviews, order_items: [:items]]])
    # ongoing_orders = customer.orders |> Enum.filter(fn x -> (x.initialStatus != "rejected" && x.isCancelled == false && x.orderOverallStatus != "delivered") end)
    modified_time = customer.orders |> Enum.map(fn x -> Map.put(x,:deliveryTime, parse_time(x.deliveryTime,"skip")) end)
    modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:orderTimeMade, parse_time(x.orderTimeMade,"skip")) end)
    modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:restaurantPreparationTime, parse_time(x.restaurantPreparationTime,"skip")) end)
    modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:updated_at, parse_time(x.updated_at |> Time.to_string(),x.updated_at |> Date.to_string() )) end)

    ongoing_orders = modified_time |> Enum.filter(fn x -> (x.initialStatus != "rejected" && x.isCancelled == false && x.orderOverallStatus != "delivered") end)
    rejected_orders = modified_time |> Enum.filter(fn x -> x.initialStatus == "rejected" end)
    cancelled_orders = modified_time |> Enum.filter(fn x -> x.isCancelled == true end)
    completed_orders = modified_time |> Enum.filter(fn x -> x.orderOverallStatus == "delivered" end)
    render conn, "orders_index.html", ongoing_orders: ongoing_orders, rejected_orders: rejected_orders, cancelled_orders: cancelled_orders, completed_orders: completed_orders
  end

  def parse_time(time_string,date_string) do

    if(String.contains?(time_string,":")) do

      time = time_string |> String.split(":") |> Enum.map(fn x -> {x,_} = Integer.parse(x)
                                                                  x end)
      today_date = Date.utc_today() |> Date.to_string()
      seconds = Enum.random(1..60)
      given_time = Time.new!(time |> Enum.at(0),time |> Enum.at(1),seconds) |> Time.to_string() |> String.split(":")
      given_time = [given_time |> Enum.at(0), given_time |> Enum.at(1), given_time |> Enum.at(2)] |> Enum.join(":")

      if(date_string !== "skip") do
        result = [date_string, given_time] |> Enum.join(" ")
      else
        result = [today_date, given_time] |> Enum.join(" ")
      end

    else
      time_string
    end
  end

  def leave_review_index(conn, _params) do
    order = Repo.get_by!(Order, id: conn.params["id"]) |> Repo.preload([:customers, :restaurants, :couriers, :reviews, order_items: [:items]])
    render conn, "leave_review.html", order: order
  end

  def leave_review(conn, _params) do
    review_params = conn.params["review"]
    changeset = Review.changeset(%Review{}, review_params)
    case Review.create(changeset, Volt.Repo) do
      {:ok, _review} ->
        conn
        |> put_flash(:info, "Your review has been successfully saved")
        |> redirect(to: Routes.customer_path(conn, :orders_index))
      {:error, _review} ->
        conn
        |> put_flash(:error, "Oops! Something went wrong. Try again!")
    end
  end
end
