defmodule VoltWeb.RestaurantController do
  use VoltWeb, :controller

  alias Volt.Accounts
  alias Volt.Accounts.Restaurant
  alias Volt.Menus.Menu
  alias Volt.Repo
  alias Volt.Items.Item
  alias Volt.Items
  alias Volt.Orders.Order
  alias Volt.Accounts.Customer

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

  def create(conn, %{"restaurant" => restaurant_params}) do

    closes_at = restaurant_params["closes_at"]
    opens_at = restaurant_params["opens_at"]
    if(correctWorkingTime(opens_at,closes_at)) do
      if(emailIsUnique(restaurant_params["email"])) do
        changeset = Restaurant.changeset(%Restaurant{}, restaurant_params)

        if(address_valid(restaurant_params["address"])) do
          case Restaurant.create(changeset, Volt.Repo) do
            {:ok, _restaurant} ->
              email = to_string(restaurant_params["email"])
              createdRestaurant = Repo.get_by!(Restaurant, email: email)
              menu = %{"restaurant_id" => createdRestaurant.id, "numberOfItems" => 0}
              menChangeset = Menu.changeset(%Menu{}, menu)
              Menu.create(menChangeset, Volt.Repo)
              conn
              |> put_flash(:info, "Restaurant and your menu have been successfully created.")
              |> redirect(to: Routes.session_path(conn,:new))
            {:error, changeset} ->
              conn
              |> put_flash(:info, "Restaurant creation failed.")
              |> render(conn, "new.html", changeset: changeset)
          end
        else
          conn
            |> put_flash(:error, "Your registration has failed: Address doesn't exists or entered in wrong format!")
            |> redirect(to: Routes.restaurant_path(conn,:new))
        end
      else
         conn
         |> put_flash(:error, "Restaurant registration has failed. Entered email exists on system!")
         |> redirect(to: Routes.restaurant_path(conn,:new))
      end
    else
      conn
      |> put_flash(:error, "Closing hours entered in wrong way. Check open and close hours!")
      |> redirect(to: Routes.restaurant_path(conn,:new))
    end
  end


  def edit(conn, %{"id" => id}) do
    restaurant = Repo.get!(Restaurant, id) |> Repo.preload([:orders])
    has_orders = restaurant.orders |> Enum.map(fn x ->
                                        if ((x.initialStatus == "pending" || x.initialStatus == "accepted") && x.orderOverallStatus != "delivered") do
                                          true
                                        end
                                      end)
    if Enum.member?(has_orders, true) do
      conn
      |> put_flash(:error, "You can't update your profile information while having ongoing orders! Please, try again later.")
      |> redirect(to: Routes.restaurant_profile_path(conn, :index))
    else
      changeset = Restaurant.changeset(restaurant, %{})
      render(conn, "edit.html", restaurant: restaurant, changeset: changeset)
    end

  end

  def update(conn, restaurant_params) do
    # restaurant = Repo.get!(Restaurant, conn.assigns.current_user.id)
    restaurant = Repo.get_by!(Restaurant, id: conn.assigns.current_user.id) |> Repo.preload([orders: [:customers, :restaurants, :couriers, order_items: [:items]]])

    orders = restaurant.orders |> Enum.filter(fn x -> x.orderOverallStatus == "delivered" end)
    # throw orders

    changeset = Restaurant.changeset(restaurant, restaurant_params)

    closes_at = restaurant_params["closes_at"]
    opens_at = restaurant_params["opens_at"]
    if(correctWorkingTime(opens_at,closes_at)) do
      if(Volt.Geolocation.address_valid(restaurant_params["address"])) do
        Repo.update(changeset)
        redirect(conn, to: Routes.restaurant_profile_path(conn, :index))
      else
        conn
        |> put_flash(:error, "Profile hasn't been edited. Address doesn't exists or entered in wrong format!")
        |> redirect(to: Routes.restaurant_profile_path(conn, :index))
      end
    else
    conn
    |> put_flash(:error, "Closing hours entered in wrong way. Check open and close hours!")
    |> redirect(to: Routes.restaurant_profile_path(conn, :index))
    end
  end

  def menuIndex(conn, %{"id" => id}) do
    restaurant = Repo.get_by!(Restaurant, id: id) |> Repo.preload([:menus])
    menu = Repo.get_by!(Menu, id: restaurant.menus.id) |> Repo.preload([:items])
    render(conn, "menuIndex.html", restaurant: restaurant, menu: menu)
  end

  def edit_item(conn, _params) do
    item = Repo.get_by!(Item, id: conn.params["id"])
    render conn, "edit_item.html", item: item
  end

  def update_item(conn, _params) do
    item = Repo.get_by!(Item, id: conn.params["id"]) |> Repo.preload([menus: [restaurants: [:orders]]])
    has_ongoing_orders = item.menus.restaurants.orders |> Enum.map(fn x -> if(x.initialStatus != "rejected" && x.orderOverallStatus != "delivered" &&     x.isCancelled == false) do true else false end end)
    if(!(has_ongoing_orders |> Enum.member?(true))) do
      changeset = Item.changeset(item, %{"name" => conn.params["item"]["name"], "category" => conn.params["item"]["category"], "description" => conn.params["item"]["description"], "price" => conn.params["item"]["price"]})
      case Repo.update(changeset) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Successfully updated the item info")
        |> redirect(to: Routes.restaurant_path(conn, :menuIndex, item.menus.restaurants.id))
      {:error, _item} ->
        conn
        |> put_flash(:error, "An error occured while updating. Please be sure that you have entered valid information and try again!")
        |> redirect(to: Routes.restaurant_path(conn, :menuIndex, item.menus.restaurants.id))
      end
    else
      conn
        |> put_flash(:error, "You can't update item information while having an ongoing order! Please try again later.")
        |> redirect(to: Routes.restaurant_path(conn, :menuIndex, item.menus.restaurants.id))
    end
  end

  def delete_item(conn, _params) do
    item = Repo.get_by!(Item, id: conn.params["id"]) |> Repo.preload([menus: [restaurants: [:orders]]])
    has_ongoing_orders = item.menus.restaurants.orders |> Enum.map(fn x -> if(x.initialStatus != "rejected" && x.orderOverallStatus != "delivered" &&     x.isCancelled == false) do true else false end end)
    if(!(has_ongoing_orders |> Enum.member?(true))) do
      case Repo.delete(item) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Successfully deleted the item")
        |> redirect(to: Routes.restaurant_path(conn, :menuIndex, item.menus.restaurants.id))
      {:error, _item} ->
        conn
        |> put_flash(:error, "An error occured while deletion!")
        |> redirect(to: Routes.restaurant_path(conn, :menuIndex, item.menus.restaurants.id))
      end
    else
      conn
        |> put_flash(:error, "You can't delete item while having an ongoing order! Please try again later.")
        |> redirect(to: Routes.restaurant_path(conn, :menuIndex, item.menus.restaurants.id))
    end
  end

  def address_valid(address) do
    [lat,long] = Volt.Geolocation.find_location(address)
    address_valid = address |> String.split(",") |> length() == 3
    lat != nil && long != nil && address_valid
  end

  defp correctWorkingTime(opens_at,closes_at) do
    openTime = opens_at |> String.split(":")
    {openHour,_} = Integer.parse(openTime |> Enum.at(0))
    {openMinute,_} = Integer.parse(openTime |> Enum.at(1))

    closeTime = closes_at |> String.split(":")
    {closeHour,_} = Integer.parse(closeTime |> Enum.at(0))
    {closeMinute,_} = Integer.parse(closeTime |> Enum.at(1))

    openHour < closeHour || closeHour == 0 && closeMinute == 0 || openHour == closeHour && openMinute < closeMinute
  end

  def ordersIndex(conn, _params) do
    restaurant = Repo.get_by!(Restaurant, id: conn.assigns.current_user.id) |> Repo.preload([orders: [:customers, :restaurants, :couriers, order_items: [:items]]])

    current_time  = Time.utc_now() |> Time.add(10800) |> Time.to_iso8601() |> String.split(":")
    cur_Hour = current_time |> Enum.at(0) |> Integer.parse()
    cur_Min = current_time |> Enum.at(1) |> Integer.parse()

    orders = restaurant.orders |> Enum.filter(fn x -> order_made = x.orderTimeMade |> String.split(":")
                                                      order_Hour = order_made  |> Enum.at(0) |> Integer.parse()
                                                      order_Min = order_made  |> Enum.at(1) |> Integer.parse()
                                                      (cur_Hour > order_Hour || (cur_Hour == order_Hour && cur_Min >= order_Min))
                                                      end)

    render conn, "ordersIndex.html", orders: orders
  end

  def update_order_time(conn, _params) do
    order_id = conn.params["id"]
    order = Repo.get_by!(Order, id: order_id)
    approxTime = conn.params["approxTime"]["time"]
    restaurant_id = conn.params["approxTime"]["restaurant_id"]

    scheduled_time = calculateTime(approxTime,restaurant_id,order.restaurantPreparationTime,order.orderTimeMade)

    if(scheduled_time != "Error") do
      estimated_time_to_deliver = Volt.Geolocation.distance(order.addressFrom, order.addressTo) |> Enum.at(1)
      additionalTime = trunc(estimated_time_to_deliver*60) + 60

      prep_time = scheduled_time |> String.split(":")
      {prep_Hours, _} = prep_time |> Enum.at(0) |> Integer.parse()
      {prep_Min, _} = prep_time |> Enum.at(1) |> Integer.parse()
      {_,prep_time} = Time.new(prep_Hours,prep_Min,0,0)
      prep_time = Time.add(prep_time,additionalTime,:second) |> Time.to_string() |> String.split(":")
      prep_time = [prep_time |> Enum.at(0), prep_time |> Enum.at(1)] |> Enum.join(":")
      # UGURLAR BRATTTTTTTTTTTTTTTTTTTTT
      # throw scheduled_time
      time_changeset = Order.changeset(order, %{"initialStatus" => "accepted", "isCancelled" => false, "restaurantPreparationTime" => scheduled_time, "deliveryTime" => prep_time, "orderRestaurantStatus" => "in-process", "rejectMessage" => "noMessage"})

      # throw time_changeset
      case Repo.update(time_changeset) do
        {:ok, _order} ->
          conn
          |> redirect(to: Routes.restaurant_path(conn, :ordersIndex))
        {:error, _order} ->
          conn
          |> put_flash(:error, "Oops! Something went wrong. Try again!")
          |> redirect(to: Routes.restaurant_path(conn, :ordersIndex))
      end


    else
      conn
      |> put_flash(:error, "Oops, something went wrong! The entered time is wrong! Please enter valid time.")
      |> redirect(to: Routes.restaurant_path(conn, :ordersIndex))
    end
  end

  def mark_order_prepared(conn, _params) do
    order = Repo.get_by!(Order, id: conn.params["id"])
    current_time  = Time.utc_now() |> Time.add(10800) |> Time.to_iso8601() |> String.split(":")
    current_time = [current_time |> Enum.at(0), current_time |> Enum.at(1)] |> Enum.join(":")
    time_changeset = Order.time_changeset(order, %{"initialStatus" => "accepted", "isCancelled" => false, "restaurantPreparationTime" => current_time, "orderRestaurantStatus" => "prepared", "rejectMessage" => "noMessage"})
    Repo.update(time_changeset)
    conn
    |> redirect(to: Routes.restaurant_path(conn, :ordersIndex))
    # throw current_time
  end

  def calculateTime(approxTime,restaurant_id,order_time,order_time_made) do
    restaurant = Repo.get_by(Restaurant, id: restaurant_id)
    open_time = restaurant.opens_at |> String.split(":") |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                      x end)
    close_time = restaurant.closes_at |> String.split(":") |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                                        x end)
    {approxTime,_} = approxTime |> Integer.parse()
    avg_delivery_time = approxTime * 60 + 10800;

    final_time = already_exist_check(order_time,avg_delivery_time,order_time_made)

    if(final_time !="Error") do
      scheduled_time = final_time |> String.split(":") |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                      x end)
      close_time_check = (close_time |> Enum.at(0) > scheduled_time |> Enum.at(0)) || (((close_time |> Enum.at(0) == scheduled_time |> Enum.at(0)) && (close_time |> Enum.at(1) > scheduled_time |> Enum.at(1)))) || (close_time |> Enum.at(0) == 0 && scheduled_time |> Enum.at(0) < 24)
      if(close_time_check && approxTime < 120) do
        final_time
      else
        "Error"
      end
    else
      "Error"
    end
  end

  def already_exist_check(order_time,avg_delivery_time,order_time_made) do
    if(order_time == "no-time") do
      if(avg_delivery_time>10800) do
        final_time = Time.utc_now() |> Time.add(avg_delivery_time) |> Time.to_iso8601() |> String.split(":")
        [final_time |> Enum.at(0),final_time |> Enum.at(1)] |> Enum.join(":")
      else
        "Error"
      end
    else
      current_time = Time.utc_now() |> Time.add(10800) |> Time.to_iso8601() |> String.split(":")
      cur_Hour = current_time |> Enum.at(0) |> Integer.parse()
      cur_Min = current_time |> Enum.at(1) |> Integer.parse()

      order_time_made = order_time_made |> String.split(":")
      order_made_Hour = order_time_made |> Enum.at(0) |> Integer.parse()
      order_made_Min = order_time_made |> Enum.at(1) |> Integer.parse()

      {splittedHour,_} = order_time |> String.split(":") |> Enum.at(0) |> Integer.parse()
      {splittedMinute,_} = order_time |> String.split(":") |> Enum.at(1) |> Integer.parse()
      {_,modified_time} = Time.new(splittedHour, splittedMinute, 0, 0)

      final_time = modified_time |> Time.add(avg_delivery_time-10800) |> Time.to_iso8601() |> String.split(":")
      final_Hour = final_time |> Enum.at(0) |> Integer.parse()
      final_Min = final_time |> Enum.at(1) |> Integer.parse()

      after_order_made = order_made_Hour < final_Hour || (final_Hour == order_made_Hour && final_Min > order_made_Min)
      after_current_time = cur_Hour < final_Hour || (final_Hour == cur_Hour && final_Min > cur_Min)

      if(after_order_made && after_current_time) do
        [final_time |> Enum.at(0),final_time |> Enum.at(1)] |> Enum.join(":")
      else
        "Error"
      end
    end
  end

  def show_order(conn, _params) do
    id = conn.params["id"]
    order = Repo.get_by!(Order, id: id) |> Repo.preload([:customers, :restaurants, :couriers, order_items: [:items]])
    render conn, "show_order.html", order: order
  end

  def reject_order(conn, _params) do
    order = Repo.get_by!(Order, id: conn.params["reject"]["id"])
    time_changeset = Order.time_changeset(order, %{"initialStatus" => "rejected", "isCancelled" => false, "restaurantPreparationTime" => "no-time", "orderRestaurantStatus" => "pending", "rejectMessage" => conn.params["reject"]["rejectMessage"]})

    refund_money(order)

    Repo.update(time_changeset)
    conn
    |> put_flash(:info, "Order has been successfully rejected. Money refunded!")
    |> redirect(to: Routes.restaurant_path(conn, :ordersIndex))
  end

  def cancel_order(conn, _params) do
    order = Repo.get_by!(Order, id: conn.params["cancel"]["id"])
    time_changeset = Order.time_changeset(order, %{"isCancelled" => true})

    refund_money(order)

    Repo.update(time_changeset)
    conn
    |> put_flash(:info, "Order has been successfully cancelled. Money refunded!")
    |> redirect(to: Routes.restaurant_path(conn, :ordersIndex))
    # order = Repo.get_by!(Order, )
  end

  def orders_history(conn, _params) do
    restaurant = Repo.get_by!(Restaurant, id: conn.assigns.current_user.id) |> Repo.preload([orders: [:customers, :couriers, order_items: [:items]]])
    if(restaurant.orders != []) do
      total_revenue = restaurant.orders |> Enum.map(fn x -> (x.deliveryFee+x.restaurantFee) end) |> Enum.reduce(fn prev, cur -> prev + cur end)
      total_revenue = total_revenue * 0.8 |> Float.round(2)

      modified_time = restaurant.orders |> Enum.map(fn x -> Map.put(x,:deliveryTime, parse_time(x.deliveryTime,"skip")) end)
      modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:orderTimeMade, parse_time(x.orderTimeMade,"skip")) end)
      modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:restaurantPreparationTime, parse_time(x.restaurantPreparationTime,"skip")) end)
      modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:updated_at, parse_time(x.updated_at |> Time.to_string(),x.updated_at |> Date.to_string() )) end)

      completed_orders = modified_time |> Enum.filter(fn x -> x.orderOverallStatus == "delivered" end)
      cancelled_orders = modified_time |> Enum.filter(fn x -> x.isCancelled == true end)
      rejected_orders = modified_time |> Enum.filter(fn x -> x.initialStatus == "rejected" end)
      render conn, "orders_history.html", completed_orders: completed_orders, cancelled_orders: cancelled_orders, rejected_orders: rejected_orders, total_revenue: total_revenue
    else
      modified_time = restaurant.orders |> Enum.map(fn x -> Map.put(x,:deliveryTime, parse_time(x.deliveryTime,"skip")) end)
      modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:orderTimeMade, parse_time(x.orderTimeMade,"skip")) end)
      modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:restaurantPreparationTime, parse_time(x.restaurantPreparationTime,"skip")) end)
      modified_time = modified_time |> Enum.map(fn x -> Map.put(x,:updated_at, parse_time(x.updated_at |> Time.to_string(),x.updated_at |> Date.to_string() )) end)

      completed_orders = modified_time |> Enum.filter(fn x -> x.orderOverallStatus == "delivered" end)
      cancelled_orders = modified_time |> Enum.filter(fn x -> x.isCancelled == true end)
      rejected_orders = modified_time |> Enum.filter(fn x -> x.initialStatus == "rejected" end)
      render conn, "orders_history.html", completed_orders: completed_orders, cancelled_orders: cancelled_orders, rejected_orders: rejected_orders, total_revenue: 0.0
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

  def refund_money(order) do
    total_order_fee = order.restaurantFee + order.deliveryFee
    id = order.customer_id
    customer = Repo.get_by!(Customer, id: id)
    final_balance = (customer.balance + total_order_fee)|> Float.round(2)

    changeset = Customer.changeset(customer, %{"balance" => final_balance})
    Repo.update(changeset)
  end
end
