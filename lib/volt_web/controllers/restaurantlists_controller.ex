defmodule VoltWeb.RestaurantlistsController do
  use VoltWeb, :controller

  alias Volt.Accounts
  alias Volt.Accounts.Restaurant
  alias Volt.Accounts.Menu
  alias Volt.Geolocation
  alias Volt.Repo
  alias Volt.Menus.Menu

  def index(conn, params) do
    if(params["session"]) do
      address_option = params["session"]["address_option"]
      input_value = params["session"]["input_value"]
      criteria = params["session"]["sort_option"]
      criteria_value = params["session"]["sort_option_input"]
      restaurants = Volt.Repo.all(Restaurant)

      if(address_option != "Searched Address") do
        input_value1 = input_value |> to_string() |>  String.split(",")
        [chosenLat, chosenLong] = [input_value1 |> Enum.at(0), input_value1 |> Enum.at(1)]

        restaurants = Volt.Repo.all(Restaurant) |> sortByCriteria(criteria, criteria_value, chosenLat,chosenLong)
        show_option = params["session"]["show_option"]

        if(show_option == "available") do
          nearby_restaurants = filterByDistance(restaurants, chosenLat ,chosenLong)
          restaraunts_string = parseRestaurantsInformation(filterByAvailability(nearby_restaurants), chosenLat ,chosenLong, "Current Location")

          render(conn, "index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
        else
          restaraunts_string = parseRestaurantsInformation(filterByDistance(restaurants,chosenLat, chosenLong), chosenLat ,chosenLong, "Current Location")
          render(conn, "index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
        end
      else
        if(Volt.Geolocation.address_valid_soft(input_value)) do
          [chosenLat, chosenLong] = Volt.Geolocation.find_location(input_value)

          restaurants = Volt.Repo.all(Restaurant) |> sortByCriteria(criteria, criteria_value, chosenLat,chosenLong)
          show_option = params["session"]["show_option"]
          if(show_option == "available") do
            nearby_restaurants = filterByDistance(restaurants, chosenLat ,chosenLong)
            restaraunts_string = parseRestaurantsInformation(filterByAvailability(nearby_restaurants), chosenLat ,chosenLong, "Searched Address")

            render(conn, "index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
          else
            restaraunts_string = parseRestaurantsInformation(filterByDistance(restaurants,chosenLat, chosenLong), chosenLat ,chosenLong, "Searched Address")
            render(conn, "index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
          end

        else
          [chosenLat, chosenLong] = Volt.Geolocation.find_location(conn.assigns.current_user.address)
          restaurants = Volt.Repo.all(Restaurant) |> sortByCriteria(criteria, criteria_value, chosenLat,chosenLong)
          show_option = params["session"]["show_option"]
          if(show_option == "available") do
            nearby_restaurants = filterByDistance(restaurants, chosenLat ,chosenLong)
            restaraunts_string = parseRestaurantsInformation(filterByAvailability(nearby_restaurants), chosenLat ,chosenLong, "Living Address")

            conn
            |> put_flash(:error, "Address not found! Pin with profile address displayed.")
            |> render("index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
          else
            restaraunts_string = parseRestaurantsInformation(filterByDistance(restaurants,chosenLat, chosenLong), chosenLat ,chosenLong, "Living Address")

            conn
            |> put_flash(:error, "Address not found! Pin with profile address displayed.")
            |> render("index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
          end
        end
      end
    else
      [chosenLat, chosenLong] = Volt.Geolocation.find_location(conn.assigns.current_user.address)
      restaurants = Volt.Repo.all(Restaurant) |> sortByCriteria("distance", "", chosenLat, chosenLong)

      restaraunts_string = parseRestaurantsInformation(filterByDistance(restaurants,chosenLat, chosenLong), chosenLat ,chosenLong, "Living Address")
      render(conn, "index.html", restaurants: restaurants, restaraunts_string: restaraunts_string)
    end
  end

  def sortByCriteria(restaurants, criteria, input, userLat, userLong) do
    if(criteria == "distance") do
      restaurants
      |> Enum.filter(fn x -> Volt.Repo.get_by(Menu,restaurant_id: x.id) && Volt.Repo.get_by(Menu,restaurant_id: x.id).numberOfItems
                            end)
      |> defaultSort(userLat, userLong)
    else
      restaurants
      |> Enum.filter(fn x -> Volt.Repo.get_by(Menu,restaurant_id: x.id) && Volt.Repo.get_by(Menu,restaurant_id: x.id).numberOfItems
                      end)
      |> Enum.filter(fn x -> String.contains?(x.tags,input) end)
      |> defaultSort(userLat, userLong)
    end
  end

  def defaultSort(restaurants, userLat, userLong) do
    available_ones = filterByAvailability(restaurants) |> Enum.sort(fn(x,y) ->
            [d1, _] = Volt.Geolocation.distance_Modified(userLat,userLong, x.address) #distance_Modified
            [d2, _] = Volt.Geolocation.distance_Modified(userLat,userLong, y.address)

            d1 <= d2
          end)

    not_available_ones = restaurants |> Enum.filter(fn (x) -> !validateAvailability([x.opens_at, x.closes_at]) end) |> Enum.sort(fn(x,y) ->
            [d1, _] = Volt.Geolocation.distance_Modified(userLat,userLong, x.address) #distance_Modified
            [d2, _] = Volt.Geolocation.distance_Modified(userLat,userLong, y.address)

            d1 <= d2
          end)

    if(available_ones == []) do
      not_available_ones
    else
      if(not_available_ones == []) do
        available_ones
      else
        available_ones ++ not_available_ones
      end
    end
  end

  def filterByDistance(restaurants, userLat, userLong) do
    restaurants
    |> Enum.filter(fn (x) -> [dist,_] = Volt.Geolocation.distance_Modified(userLat,userLong, x.address)
                              dist < 1.0 end)
  end

  def filterByAvailability(restaurants) do
    restaurants
    |> Enum.filter(fn (x) -> givenTime = [x.opens_at, x.closes_at]
                              validateAvailability(givenTime) end)
  end

  def parseRestaurantsInformation(restaurants,lat,long,address_option) do
    restaurants_info = restaurants |> Enum.map(fn(el) ->
      description = "Open at: #{el.opens_at}.
                             Close at: #{el.closes_at}.
                             Likes: #{el.likes}.
                             Dislikes: #{el.dislikes}"
      [lat,long] = Volt.Geolocation.find_location(el.address)
      el.name <> "/" <> "#{lat}" <> "/" <> "#{long}" <> "/" <> description <> "/" <> to_string(el.id) end) |> Enum.join("|")

    user_address = "#{address_option}/#{lat}/#{long}"
    if(restaurants_info != "") do
      all_info = [user_address,restaurants_info] |> Enum.join("|")
      all_info
    else
      user_address
    end
  end


  def validateAvailability(givenTime) do
    time = Time.utc_now()
    currentHour = (time.hour+3)
    currentMin = time.minute

    openTime = givenTime |> Enum.at(0) |> String.split(":")
    {openHour,_} = Integer.parse(openTime |> Enum.at(0))
    {openMinute,_} = Integer.parse(openTime |> Enum.at(1))

    closeTime = givenTime |> Enum.at(1) |> String.split(":")
    {closeHour,_} = Integer.parse(closeTime |> Enum.at(0))
    {closeMinute,_} = Integer.parse(closeTime |> Enum.at(1))

    pastOpenTime = currentHour > openHour || (currentHour == openHour && currentMin >= openMinute)
    beforeCloseTime = currentHour < closeHour || (currentHour == closeHour && currentMin < closeMinute) || (closeHour == 0 && currentHour < 24)

    pastOpenTime && beforeCloseTime
  end
end
