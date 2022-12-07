defmodule VoltWeb.CourierController do
  use VoltWeb, :controller

  alias Volt.Accounts.Courier
  alias Volt.Repo
  alias Volt.Orders.Order

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

  def create(conn, %{"courier" => courier_params}) do

    if(emailIsUnique(courier_params["email"])) do
      changeset = Courier.changeset(%Courier{}, courier_params)
      case Courier.create(changeset, Volt.Repo) do
        {:ok, _courier} ->
          conn
          |> put_flash(:info, "Courier created successfully.")
          |> redirect(to: Routes.session_path(conn,:new))
        {:error, changeset} ->
          conn
          |> put_flash(:info, "Courier creation failed.")
          |> render(conn, "new.html", changeset: changeset)
      end
    else
       conn
       |> put_flash(:error, "Courier creation failed. Email exists in system.")
       |> redirect(to: Routes.courier_path(conn,:new))
    end
  end

  def edit(conn, %{"id" => id}) do
    courier = Repo.get!(Courier, id) |> Repo.preload([:orders])
    if(courier.status != "On delivery") do
      changeset = Courier.changeset(courier, %{})
      render(conn, "edit.html", courier: courier, changeset: changeset)
    else
      conn
      |> put_flash(:info, "You can not update your profile information while being on delivery! Please visit when you don't have ongoin order!")
      |> redirect(to: Routes.page_path(conn, :index))
    end

  end

  def update(conn, courier_params) do
    courier = Repo.get!(Courier, conn.assigns.current_user.id)
    changeset = Courier.changeset(courier, courier_params)

    Repo.update(changeset)
    redirect(conn, to: Routes.courier_profile_path(conn, :index))
  end

  def address_selection_process(conn, _params) do
    # throw conn.params
    address = conn.params["session"]["input_value"]
    # throw Volt.Geolocation.address_valid_soft(address)
    if(Volt.Geolocation.address_valid_soft(address)) do
      conn
      |> redirect(to: Routes.courier_path(conn, :available_orders_index, address))
    else
      conn
      |> redirect(to: Routes.courier_path(conn, :available_orders_index))
    end
    # conn
    # |> redirect(to: Routes.courier_path(conn, :available_orders_index))
  end

  def available_orders_index(conn, _params) do
    # throw conn.params
    courier = Repo.get_by!(Courier, id: conn.assigns.current_user.id)
    courier_current_address = conn.params["address"]
    orders = Repo.all(Order) |> Repo.preload([:customers, :restaurants, :couriers, order_items: [:items]])
    rejectedOrders = courier.rejectedOrders

    if(rejectedOrders != "") do

      rejectedOrders = rejectedOrders |> String.split(",") |> Enum.map(fn y -> {y1,_} = Integer.parse(y)
                                                                                y1 end)

      orders = orders |> Enum.filter(fn x -> x.orderRestaurantStatus != "pending" && x.courier_id == 1 && x.initialStatus == "accepted" && x.isCancelled == false && x.orderOverallStatus != "delivered" end)

      orders = orders |> Enum.filter(fn x -> (Volt.Geolocation.distance(x.addressFrom, courier_current_address) |> Enum.at(0)) < 7 end)
      orders = orders |> Enum.filter(fn x ->  contains = rejectedOrders |> Enum.filter(fn y -> y == x.id end)
                                            contains==[] end)
      if (orders != []) do
        if(courier.status == "Available") do
          estimated_time_to_deliver = orders |> Enum.map(fn x -> (Volt.Geolocation.distance(x.addressFrom, x.addressTo) |> Enum.at(1)) end)
          order_array = orders |> Enum.map(fn x -> x.id end)
          order_times = Enum.zip(order_array, estimated_time_to_deliver) |> Enum.into(%{})

          # throw order_times
          render conn, "available_orders.html", orders: orders, order_times: order_times, courier_current_address: courier_current_address
        else
          conn
          |> put_flash(:info, "Please change your status to Available to view the orders!")
          |> redirect(to: Routes.courier_path(conn, :address_selection))
        end
      else
        conn
        |> put_flash(:info, "There is not any available order for your current location!")
        |> redirect(to: Routes.courier_path(conn, :address_selection))
      end
    else
      if (courier.status == "Available") do
        orders = orders |> Enum.filter(fn x -> x.orderRestaurantStatus != "pending" && x.courier_id == 1 && x.initialStatus == "accepted" && x.isCancelled == false && x.orderOverallStatus != "delivered" end)
        orders = orders |> Enum.filter(fn x -> (Volt.Geolocation.distance(x.addressFrom, courier_current_address) |> Enum.at(0)) < 7 end)

        if (orders != []) do
          estimated_time_to_deliver = orders |> Enum.map(fn x -> (Volt.Geolocation.distance(x.addressFrom, x.addressTo) |> Enum.at(1)) end)
          order_array = orders |> Enum.map(fn x -> x.id end)
          order_times = Enum.zip(order_array, estimated_time_to_deliver) |> Enum.into(%{})

          # throw order_times
          render conn, "available_orders.html", orders: orders, order_times: order_times, courier_current_address: courier_current_address
        else
          conn
          |> put_flash(:info, "There is not any available order for your current location!")
          |> redirect(to: Routes.courier_path(conn, :address_selection))
        end
      else
        conn
          |> put_flash(:info, "Please change your status to Available to view the orders!")
          |> redirect(to: Routes.courier_path(conn, :address_selection))
      end
    end
  end

  def address_selection(conn, _params) do
    courier = Repo.get_by!(Courier, id: conn.assigns.current_user.id) |> Repo.preload([:orders])

    if(courier.orders != []) do
      courier_has_ongoing_order = courier.orders |> Enum.map(fn x ->
                                                      if x.orderOverallStatus == "delivered" do false else true end
                                                    end)
      if(courier_has_ongoing_order |> Enum.member?(true)) do
        conn
        |> put_flash(:error, "You can't view available orders while having ongoing orders! Please complete your order.")
        |> redirect(to: Routes.page_path(conn, :index))
      else
        render conn, "address_selection.html"
      end
    else
      render conn, "address_selection.html"
    end
  end

  def accept_order(conn, _params) do
    # throw conn.params
    courier = Repo.get_by!(Courier, id: conn.params["session"]["courier_id"])
    order = Repo.get_by!(Order, id: conn.params["id"])

    # estimated_time_to_deliver = Volt.Geolocation.distance(order.addressFrom, order.addressTo) |> Enum.at(1)

    # throw estimated_time_to_deliver
    # estimated_time_to_deliver = orders |> Enum.map(fn x -> (Volt.Geolocation.distance(x.addressFrom, x.addressTo) |> Enum.at(1)) end)

    # order_times |> Enum.map(fn {x,z} ->

    # additionalTime = trunc(estimated_time_to_deliver*60) + 60

    # prep_time = order.restaurantPreparationTime |> String.split(":")
    # {prep_Hours, _} = prep_time |> Enum.at(0) |> Integer.parse()
    # {prep_Min, _} = prep_time |> Enum.at(1) |> Integer.parse()
    # {_,prep_time} = Time.new(prep_Hours,prep_Min,0,0)
    # prep_time = Time.add(prep_time,additionalTime,:second) |> Time.to_string() |> String.split(":")
    # prep_time = [prep_time |> Enum.at(0), prep_time |> Enum.at(1)] |> Enum.join(":")

    if order.courier_id == 1 do
      # assign courier to the order
      changeset = Order.changeset(order, %{"courier_id" => courier.id})

      courier_changeset = Courier.changeset(courier, %{"status" => "On delivery"})
      case Repo.update(changeset) && Repo.update(courier_changeset) do
        {:ok, _order} ->
          conn
          |> put_flash(:info, "Order has been assigned to you! View order details in your orders page!")
          |> redirect(to: Routes.page_path(conn, :index))
        {:error, _order} ->
          conn
          |> put_flash(:error, "Something went wrong. Order couldn't be assigned to you!")
      end
    else
      # Redirect to previous page with error message
      conn
      |> put_flash(:error, "Order has been assigned to other courier. Please try another order!")
      |> redirect(to: Routes.page_path(conn, :index))
    end
    # throw order
  end

  def reject_order(conn, _params) do
    courier = Repo.get_by!(Courier, id: conn.params["reject"]["courier_id"])
    order = Repo.get_by!(Order, id: conn.params["id"])
    alreadyRejected = courier.rejectedOrders
    if(alreadyRejected != "" && String.contains?(alreadyRejected, ",")) do
      alreadyRejected = alreadyRejected |> String.split(",")

      updated = Enum.concat(alreadyRejected,["#{order.id}"]) |> Enum.join(",")
      changeset = Courier.changeset(courier, %{"rejectedOrders" => updated})
      case Repo.update(changeset) do
          {:ok, _order} ->
            conn
            |> put_flash(:info, "You rejected available order. It won't be visible to you anymore!")
            |> redirect(to: Routes.page_path(conn, :index))
          {:error, _order} ->
            conn
            |> put_flash(:error, "Order rejection is not successful!")
      end
    else
      if(alreadyRejected == "") do
        updated = "#{order.id}"
        changeset = Courier.changeset(courier, %{"rejectedOrders" => updated})
        case Repo.update(changeset) do
          {:ok, _order} ->
            conn
            |> put_flash(:info, "You rejected available order. It won't be visible to you anymore!")
            |> redirect(to: Routes.page_path(conn, :index))
          {:error, _order} ->
            conn
            |> put_flash(:error, "Order rejection is not successful!")
        end
      else
        updated = Enum.concat([alreadyRejected],["#{order.id}"]) |> Enum.join(",")
        changeset = Courier.changeset(courier, %{"rejectedOrders" => updated})
        case Repo.update(changeset) do
          {:ok, _order} ->
            conn
            |> put_flash(:info, "You rejected available order. It won't be visible to you anymore!")
            |> redirect(to: Routes.page_path(conn, :index))
          {:error, _order} ->
            conn
            |> put_flash(:error, "Order rejection is not successful!")
        end
      end
    end
  end

  def orders_index(conn, _params) do
    courier = Repo.get_by!(Courier, id: conn.assigns.current_user.id) |> Repo.preload([orders: [:customers, :restaurants, order_items: [:items]]])
    # ongoing_orders = customer.orders |> Enum.filter(fn x -> (x.initialStatus != "rejected" && x.isCancelled == false && x.orderOverallStatus != "delivered") end)
    # throw other_orders
    modified_time = courier.orders |> Enum.map(fn x -> Map.put(x,:deliveryTime, parse_time(x.deliveryTime,"skip")) end)
    modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:orderTimeMade, parse_time(x.orderTimeMade,"skip")) end)
    modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:restaurantPreparationTime, parse_time(x.restaurantPreparationTime,"skip")) end)
    modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:updated_at, parse_time(x.updated_at |> Time.to_string(),x.updated_at |> Date.to_string() )) end)

    ongoing_orders = modified_time |> Enum.filter(fn x -> (x.initialStatus != "rejected" && x.isCancelled == false && x.orderOverallStatus != "delivered") end)
    completed_orders = modified_time |> Enum.filter(fn x -> x.orderOverallStatus == "delivered" end)

    if(courier.orders != []) do
      total_revenue = courier.orders |> Enum.map(fn x -> x.deliveryFee end) |> Enum.reduce(fn prev, cur -> prev + cur end)
      render conn, "orders_index.html", ongoing_orders: ongoing_orders, completed_orders: completed_orders, total_revenue: total_revenue
    else
      render conn, "orders_index.html", ongoing_orders: ongoing_orders, completed_orders: completed_orders, total_revenue: 0.0
    end
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

  def complete_order(conn, _params) do
    order = Repo.get_by!(Order, id: conn.params["id"])
    courier = Repo.get_by!(Courier, id: conn.assigns.current_user.id)
    if (order.orderRestaurantStatus == "prepared") do
      changeset = Order.changeset(order, %{"orderOverallStatus" => "delivered"})
      case Repo.update(changeset) do
        {:ok, _order} ->
          courier_changeset = Courier.changeset(courier, %{"status" => "Available"})
          case Repo.update(courier_changeset) do
            {:ok, _courier} ->
              conn
              |> put_flash(:info, "You have successfully completed the order and your status was changed  to Available!")
              |> redirect(to: Routes.courier_path(conn, :orders_index))
            {:error, _courier} ->
              conn
              |> put_flash(:info, "Order successfully finished but your status coulnd't be changed!")
              |> redirect(to: Routes.courier_path(conn, :orders_index))
          end
        {:error, _order} ->
          conn
          |> put_flash(:info, "Order couldn't be completed!")
          |> redirect(to: Routes.courier_path(conn, :orders_index))
      end
    else
      conn
          |> put_flash(:error, "You can't finish in-process order!")
          |> redirect(to: Routes.courier_path(conn, :orders_index))
    end
  end
end
