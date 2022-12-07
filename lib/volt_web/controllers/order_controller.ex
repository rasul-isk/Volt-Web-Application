defmodule VoltWeb.OrderController do
  use VoltWeb, :controller
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

  # def index(conn, params) do
  #   customer = Repo.get_by!(Customer, id: conn.assigns.current_user.id) |> Repo.preload([:orders])
  #   orders = customer.orders |> Enum.map(fn x -> Repo.get_by!(Order, id: x.id) |> Repo.preload([:order_items]) end)
  #   # order_items_data = orders |> Enum.map(fn x -> x.order_items |> Enum.map(fn y -> Repo.get_by!(Item, id: y.item_id) end) end)
  #   order_items_data = orders |> Enum.map(fn x -> x.order_items |> Repo.preload([:items]) end)
  #   if(order_items_data != []) do
  #     order_items_data = order_items_data |> Enum.reduce(fn (prev, cur) -> cur ++ prev end)
  #     render conn, "index.html", customer: customer, orders: orders, order_items_data: order_items_data
  #   else
  #     render conn, "index.html", customer: customer, orders: orders, order_items_data: order_items_data
  #   end

  # end

  # def restaurantIndex(conn, _params) do
  #   restaurant = Repo.get_by!(Restaurant, id: conn.assigns.current_user.id) |> Repo.preload([:orders])
  #   render conn, "restaurantIndex.html"
  # end


  def create_order(conn, _params) do
    {final_fee,_} = conn.params["items"]["item-final-fee"] |> Float.parse()
    user_balance = conn.assigns.current_user.balance

    orderTimeMade = conn.params["items"]["orderTimeMade"] |> String.split(":")  |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                                              x end)
    isScheduled = conn.params["items"]["isScheduled"] == "false" && false
    isScheduled = conn.params["items"]["isScheduled"] == "true" && true || isScheduled

    current_time  = Time.utc_now() |> Time.add(10800) |> Time.to_string() |> String.split(":") |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                                                            x end)


    close_time = conn.params["items"]["close_time"] |> String.split(":") |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                                              x end)
    close_time_check = (close_time |> Enum.at(0) > orderTimeMade |> Enum.at(0)) || ((close_time |> Enum.at(0) == orderTimeMade |> Enum.at(0)) && (close_time |> Enum.at(1) > orderTimeMade |> Enum.at(1))) || (close_time |> Enum.at(0) == 0 && orderTimeMade |> Enum.at(0) < 24)


    open_time = conn.params["items"]["open_time"] |> String.split(":") |> Enum.map(fn x -> {x, _} = Integer.parse(x)
                                                                                                      x end)
    open_time_check = (open_time |> Enum.at(0) < orderTimeMade |> Enum.at(0)) || ((open_time |> Enum.at(0) == orderTimeMade |> Enum.at(0)) && (open_time |> Enum.at(1) < orderTimeMade |> Enum.at(1)))

    current_time_check = (current_time |> Enum.at(0) < orderTimeMade |> Enum.at(0)) || ((current_time |> Enum.at(0) == orderTimeMade |> Enum.at(0)) && (current_time |> Enum.at(1) < orderTimeMade |> Enum.at(1)))

    if(final_fee < user_balance) do
      returnedItems = conn.params["items"] |> Map.filter(fn {x, y} -> !String.contains?(x, "item-total") end)
      keys = Map.keys(returnedItems)
      item_keys = keys |> Enum.filter(fn x -> String.contains?(x, "item") end) |> Enum.sort()
      noOfItems = ((Enum.count(item_keys)) / 6) |> trunc()
      amounts = item_keys |> Enum.take(noOfItems)
      allItemAmounts = Enum.map(amounts, fn x ->
                              val = Map.fetch!(returnedItems, x)
                              if val != "0" do
                                x
                              end
                            end)
      if(conn.params["items"]["item-total-all"] != "0") do
        if (!isScheduled || (isScheduled && open_time_check && close_time_check && current_time_check)) do
        updated_balance = user_balance - final_fee |> Float.round(2)
        customer = Repo.get!(Customer, conn.assigns.current_user.id)
        changeset = Customer.changeset(customer, %{"balance" => updated_balance})
        Repo.update(changeset)

        selectedItemsAmounts = Enum.filter(allItemAmounts, fn x -> x != nil end)
        selectedItemIds = Enum.map(selectedItemsAmounts, fn x -> String.slice(x, 12..(String.length(x) - 1)) end) #array of IDs
        selectedItemsAmounts = Enum.map(selectedItemsAmounts, fn x ->
                                Map.fetch!(returnedItems, x)
                              end) #array of ammounts
        order_params = Map.drop(returnedItems, item_keys)
        changeset = Order.changeset(%Order{}, order_params)
        case Order.create(changeset, Volt.Repo) do
          {:ok, order} ->
            length = selectedItemIds |> Enum.count()
            for n <- 0..(length-1) do
                item_id = selectedItemIds |> Enum.at(n)
                quantity = selectedItemsAmounts |> Enum.at(n)
                new_era = %{"order_id"=> order.id, "item_id" => item_id, "quantity" => quantity, "status" => "Ordered"}

                changeset = OrderItem.changeset(%OrderItem{}, new_era)

                OrderItem.create(changeset, Volt.Repo)
              end
            planned_to_create = selectedItemIds |> Enum.count()
            created = OrderItem.count(order.id)
            if(planned_to_create == created) do
              conn
              |> put_flash(:info, "Order created succesfully. Money withdrawed from card balance.")
              |> redirect(to: Routes.page_path(conn, :index))
            else
              conn
              |> put_flash(:error, "Not all items had been accepted to order.")
              |> redirect(to: Routes.page_path(conn, :index))
            end
          {:error, _} ->
            conn
            |> put_flash(:error, "Error occured while placing order. Order is not placed.")
            |> redirect(to: Routes.public_restaurant_path(conn,:index, conn.params["items"]["restaurant_id"], chosen_address: conn.params["items"]["addressTo"]))
        end

        else
        conn
        |> put_flash(:error, "Order is not placed. Wrong time selected or you are trying to place an order from currently unavailable restaurant!")
        |> redirect(to: Routes.public_restaurant_path(conn,:index, conn.params["items"]["restaurant_id"], chosen_address: conn.params["items"]["addressTo"]))
        end
      else
      conn
      |> put_flash(:error, "Order is not placed. Please, choose at least one item.")
      |> redirect(to: Routes.public_restaurant_path(conn,:index, conn.params["items"]["restaurant_id"], chosen_address: conn.params["items"]["addressTo"]))

      end
    else
      conn
      |> put_flash(:error, "Order couldn't be placed due to insufficient amount of funds on card.")
      |> redirect(to: Routes.public_restaurant_path(conn,:index, conn.params["items"]["restaurant_id"], chosen_address: conn.params["items"]["addressTo"]))
    end
  end
end
