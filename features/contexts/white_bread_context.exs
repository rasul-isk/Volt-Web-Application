defmodule WhiteBreadContext do

  use WhiteBread.Context
  use Hound.Helpers
  alias Volt.Accounts.Courier
  alias Volt.Accounts.Restaurant
  alias Volt.Accounts.Customer

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn _state ->
    Hound.start_session
    %{}
  end

  scenario_finalize fn _status, _state ->
    # Hound.end_session
    nil
  end

  #########################################################################################################
  #
  #
  # User Registration
  #
  #
  #########################################################################################################

  #########################################################################################################
  #
  # Customer
  #
  #########################################################################################################
  and_ ~r/^I open customer registration page$/, fn state ->
    navigate_to "/new-customer"
    {:ok, state}
  end

  and_ ~r/^My customer name is "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    {:ok, state |> Map.put(:name, name)}
  end

  and_ ~r/^I enter my customer name$/, fn state ->
    fill_field({:id, "name"}, state[:name])
    {:ok, state}
  end

  and_ ~r/^My customer email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I enter my customer email$/, fn state ->
    fill_field({:id, "email"}, state[:email])
    {:ok, state}
  end

  and_ ~r/^I want my customer password to be "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my customer password$/, fn state ->
    fill_field({:id, "crypted_password"}, state[:password])
    {:ok, state}
  end

  and_ ~r/^My date of birth is "(?<dateofbirth>[^"]+)"$/, fn state, %{dateofbirth: dateofbirth} ->
    {:ok, state |> Map.put(:dateofbirth, dateofbirth)}
  end

  and_ ~r/^I enter my date of birth$/, fn state ->
    fill_field({:id, "dateofbirth"}, state[:dateofbirth])
    {:ok, state}
  end

  and_ ~r/^My address is "(?<address>[^"]+)"$/, fn state, %{address: address} ->
    {:ok, state |> Map.put(:address, address)}
  end

  and_ ~r/^I enter my address$/, fn state ->
    click({:id, "custom-radio-button"})
    fill_field({:id, "address"}, state[:address])
    {:ok, state}
  end

  and_ ~r/^My card number is "(?<cardnumber>[^"]+)"$/, fn state, %{cardnumber: cardnumber} ->
    {:ok, state |> Map.put(:cardnumber, cardnumber)}
  end

  and_ ~r/^I enter my card number$/, fn state ->
    fill_field({:id, "cardnumber"}, state[:cardnumber])
    {:ok, state}
  end

  when_ ~r/^I submit the customer registration form$/, fn state ->
    click({:id, "submit_customer"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for customer registration$/, fn state ->
    assert visible_in_page? ~r/You have successfully registered. Please login to place your orders!/
    {:ok, state}
  end

  given_ ~r/^The following customer$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should see error message for customer registration$/, fn state ->
    assert visible_in_page? ~r/Your registration has failed. Entered email exists on system./
    {:ok, state}
  end

  #########################################################################################################
  #
  # Courier
  #
  #########################################################################################################

  and_ ~r/^I open courier registration page$/, fn state ->
    navigate_to "/new-courier"
    {:ok, state}
  end

  and_ ~r/^My courier name is "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    {:ok, state |> Map.put(:name, name)}
  end

  and_ ~r/^I enter my courier name$/, fn state ->
    fill_field({:id, "name"}, state[:name])
    {:ok, state}
  end

  and_ ~r/^My courier email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I enter my courier email$/, fn state ->
    fill_field({:id, "email"}, state[:email])
    {:ok, state}
  end

  and_ ~r/^I want my courier password to be "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my courier password$/, fn state ->
    fill_field({:id, "crypted_password"}, state[:password])
    {:ok, state}
  end

  when_ ~r/^I submit the courier registration form$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for courier registration$/, fn state ->
    assert visible_in_page? ~r/Courier created successfully./
    {:ok, state}
  end

  given_ ~r/^The following courier$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should see error message for courier registration$/, fn state ->
    assert visible_in_page? ~r/Courier creation failed. Email exists in system./
    {:ok, state}
  end

  #########################################################################################################
  #
  # Restaurant
  #
  #########################################################################################################

  and_ ~r/^I open restaurant registration page$/, fn state ->
    navigate_to "/new-restaurant"
    {:ok, state}
  end

  and_ ~r/^My restaurant name is "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    {:ok, state |> Map.put(:name, name)}
  end

  and_ ~r/^I enter my restaurant name$/, fn state ->
    fill_field({:id, "name"}, state[:name])
    {:ok, state}
  end

  and_ ~r/^My restaurant email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I enter my restaurant email$/, fn state ->
    fill_field({:id, "email"}, state[:email])
    {:ok, state}
  end

  and_ ~r/^I want my restaurant password to be "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my restaurant password$/, fn state ->
    fill_field({:id, "crypted_password"}, state[:password])
    {:ok, state}
  end

  and_ ~r/^I choose my restaurant category$/, fn state ->
    click({:id, "pizza-radio-button"})
    {:ok, state}
  end

  and_ ~r/^I choose my tags$/, fn state ->
    click({:id, "fast-food-check"})
    click({:id, "american-check"})
    {:ok, state}
  end

  and_ ~r/^My restaurant address is "(?<address>[^"]+)"$/, fn state, %{address: address} ->
    {:ok, state |> Map.put(:address, address)}
  end

  and_ ~r/^I enter my restaurant address$/, fn state ->
    fill_field({:id, "address"}, state[:address])
    {:ok, state}
  end

  and_ ~r/^My opening hour is "(?<opens_at>[^"]+)"$/, fn state, %{opens_at: opens_at} ->
    {:ok, state |> Map.put(:opens_at, opens_at)}
  end

  and_ ~r/^I enter my opening hour$/, fn state ->
    fill_field({:id, "opens_at"}, state[:opens_at])
    {:ok, state}
  end

  and_ ~r/^My closing hour is "(?<closes_at>[^"]+)"$/, fn state, %{closes_at: closes_at} ->
    {:ok, state |> Map.put(:closes_at, closes_at)}
  end

  and_ ~r/^I enter my closing hour$/, fn state ->
    fill_field({:id, "closes_at"}, state[:closes_at])
    {:ok, state}
  end

  and_ ~r/My restaurant description is "(?<description>[^"]+)"$/, fn state, %{description: description} ->
    {:ok, state |> Map.put(:description, description)}
  end

  and_ ~r/I enter my restaurant description$/, fn state ->
    fill_field({:id, "description"}, state[:description])
    {:ok, state}
  end

  when_ ~r/^I submit the restaurant registration form$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for restaurant registration$/, fn state ->
    assert visible_in_page? ~r/Restaurant and your menu have been successfully created./
    {:ok, state}
  end

  given_ ~r/^The following restaurant$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should see error message for restaurant registration$/, fn state ->
    assert visible_in_page? ~r/Restaurant registration has failed. Entered email exists on system!/
    {:ok, state}
  end

  #########################################################################################################
  #
  #
  # Reset password
  #
  #
  #########################################################################################################

  given_ ~r/^the following user with password$/, fn state, %{table_data: table} ->
    table
        |> Enum.map(fn customer -> Customer.changeset(%Customer{}, customer) end)
        |> Enum.each(fn changeset -> Volt.Repo.insert!(changeset) end)
        {:ok, state}
  end

  and_ ~r/^I open reset password page$/, fn state ->
    navigate_to "/password-reset/new"
    {:ok, state}
  end

  and_ ~r/^My existing email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I input my email$/, fn state ->
    element = find_element(:id, "email")
    fill_field(element, state[:email])
    {:ok, state}
  end

  and_ ~r/^I click send password reset email button$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  and_ ~r/^I open inbox$/, fn state ->
    click({:id, "inbox_button"})
    {:ok, state}
  end

  and_ ~r/^I click on the link to open reset password page$/, fn state ->
    iframe = find_element(:tag, "iframe")
    focus_frame(iframe)
    link = find_element(:id, "reset_password_url")
    click(link)
    {:ok, state}
  end

  # password_field

  and_ ~r/^I want my new password to be "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my new password$/, fn state ->
    focus_window(Enum.at(window_handles(), 1))
    fill_field({:id, "crypted_password"}, state[:password])
    {:ok, state}
  end

  when_ ~r/^I click save$/, fn state ->
    element = find_element(:id, "submit_button")
    click(element)
    {:ok, state}
  end

  then_ ~r/^I should see success message for password reset$/, fn state ->
    assert visible_in_page? ~r/Your password has been reset. Sign in below with your new password./
    {:ok, state}
  end

  then_ ~r/^I should see error message for password reset$/, fn state ->
    assert visible_in_page? ~r/No email exists/
    {:ok, state}
  end

  #########################################################################################################
  #
  #
  # User login
  #
  #
  #########################################################################################################

  #########################################################################################################
  #
  # Customer
  #
  #########################################################################################################

  given_ ~r/^The following existing customer$/, fn state, %{table_data: table} ->
    table
        |> Enum.map(fn customer -> Customer.changeset(%Customer{}, customer) end)
        |> Enum.each(fn changeset -> Volt.Repo.insert!(changeset) end)
        {:ok, state}
  end

  and_ ~r/^I open login page as customer$/, fn state ->
    navigate_to "/sessions/new"
    {:ok, state}
  end

  and_ ~r/^My existing customer email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I enter my existing customer email$/, fn state ->
    fill_field({:id, "email"}, state[:email])
    {:ok, state}
  end

  and_ ~r/^My existing customer password is "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my existing customer password$/, fn state ->
    fill_field({:id, "password"}, state[:password])
    {:ok, state}
  end

  and_ ~r/^I choose customer role$/, fn state ->
    click({:id, "customer-radio"})
    {:ok, state}
  end

  when_ ~r/^I click login button as customer$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see welcome message for customer login$/, fn state ->
    assert visible_in_page? ~r/Welcome .+/
    {:ok, state}
  end

  then_ ~r/^I should see error message for customer login$/, fn state ->
    assert visible_in_page? ~r/Wrong email or password./
    {:ok, state}
  end

  #########################################################################################################
  #
  # Courier
  #
  #########################################################################################################

  given_ ~r/^The following existing courier$/, fn state, %{table_data: table} ->
    table
        |> Enum.map(fn courier -> Courier.changeset(%Courier{}, courier) end)
        |> Enum.each(fn changeset -> Volt.Repo.insert!(changeset) end)
    {:ok, state}
  end

  and_ ~r/^I open login page as courier$/, fn state ->
    navigate_to "/sessions/new"
    {:ok, state}
  end

  and_ ~r/^My existing courier email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I enter my existing courier email$/, fn state ->
    fill_field({:id, "email"}, state[:email])
    {:ok, state}
  end

  and_ ~r/^My existing courier password is "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my existing courier password$/, fn state ->
    fill_field({:id, "password"}, state[:password])
    {:ok, state}
  end

  and_ ~r/^I choose courier role$/, fn state ->
    click({:id, "courier-radio"})
    {:ok, state}
  end

  when_ ~r/^I click login button as courier$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see welcome message for courier login$/, fn state ->
    assert visible_in_page? ~r/Welcome .+/
    {:ok, state}
  end

  then_ ~r/^I should see error message for courier login$/, fn state ->
    assert visible_in_page? ~r/Wrong email or password./
    {:ok, state}
  end

  #########################################################################################################
  #
  # Restaurant
  #
  #########################################################################################################

  given_ ~r/^The following existing restaurant$/, fn state, %{table_data: table} ->
    table
        |> Enum.map(fn restaurant -> Restaurant.changeset(%Restaurant{}, restaurant) end)
        |> Enum.each(fn changeset -> Volt.Repo.insert!(changeset) end)
    {:ok, state}
  end

  and_ ~r/^I open login page as restaurant$/, fn state ->
    navigate_to "/sessions/new"
    {:ok, state}
  end

  and_ ~r/^My existing restaurant email is "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    {:ok, state |> Map.put(:email, email)}
  end

  and_ ~r/^I enter my existing restaurant email$/, fn state ->
    fill_field({:id, "email"}, state[:email])
    {:ok, state}
  end

  and_ ~r/^My existing restaurant password is "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    {:ok, state |> Map.put(:password, password)}
  end

  and_ ~r/^I enter my existing restaurant password$/, fn state ->
    fill_field({:id, "password"}, state[:password])
    {:ok, state}
  end

  and_ ~r/^I choose restaurant role$/, fn state ->
    click({:id, "restaurant-radio"})
    {:ok, state}
  end

  when_ ~r/^I click login button as restaurant$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see welcome message for restaurant login$/, fn state ->
    assert visible_in_page? ~r/Welcome .+/
    {:ok, state}
  end

  then_ ~r/^I should see error message for restaurant login$/, fn state ->
    assert visible_in_page? ~r/Wrong email or password./
    {:ok, state}
  end

  #########################################################################################################
  #
  #
  # Update profile
  #
  #
  #########################################################################################################
  #########################################################################################################
  #
  # User
  #
  #########################################################################################################

  given_ ~r/^Customer with email "(?<email>[^"]+)" and password "(?<password>[^"]+)" is logged in$/, fn state, %{email: email, password: password} ->
    navigate_to "/sessions/new"
    fill_field({:id, "email"}, email)
    fill_field({:id, "password"}, password)
    click({:id, "customer-radio"})
    click({:id, "submit_button"})
    {:ok, state}
  end

  and_ ~r/^I open my profile page as customer$/, fn state ->
    navigate_to "/customer/profile"
    {:ok, state}
  end

  and_ ~r/^I click edit information button as customer$/, fn state ->
    click({:id, "edit-info-button"})
    {:ok, state}
  end

  and_ ~r/^I change my existing cardnumber as customer to "(?<cardnumber>[^"]+)"$/, fn state, %{cardnumber: cardnumber} ->
    fill_field({:id, "cardnumber"}, cardnumber)
    {:ok, state}
  end

  and_ ~r/^I change my existing name as customer to "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    fill_field({:id, "name"}, name)
    {:ok, state}
  end

  when_ ~r/^I click update information button as customer$/, fn state ->
    click({:id, "submit-button"})
    {:ok, state}
  end

  then_ ~r/^I should see updated customer credit card number "(?<cardnumber>[^"]+)"$/, fn state, %{cardnumber: cardnumber} ->
    creditcard = find_element(:id, "creditcard")
    number = inner_text(creditcard)
    assert number == cardnumber
    {:ok, state}
  end

  then_ ~r/^I should see my customer name unchanged "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    name_element = find_element(:id, "name")
    name_text = inner_text(name_element)
    assert name == name_text
    {:ok, state}
  end

  #########################################################################################################
  #
  # Courier
  #
  #########################################################################################################

  given_ ~r/^Courier with email "(?<email>[^"]+)" and password "(?<password>[^"]+)" is logged in$/, fn state, %{email: email, password: password} ->
    navigate_to "/sessions/new"
    fill_field({:id, "email"}, email)
    fill_field({:id, "password"}, password)
    click({:id, "courier-radio"})
    click({:id, "submit_button"})
    {:ok, state}
  end

  and_ ~r/^I open my profile page as courier$/, fn state ->
    navigate_to "/courier/profile"
    {:ok, state}
  end

  and_ ~r/^I click edit information button as courier$/, fn state ->
    click({:id, "edit-info-button"})
    {:ok, state}
  end

  and_ ~r/^I change my existing name as courier to "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    fill_field({:id, "name"}, name)
    {:ok, state}
  end

  and_ ~r/^I change my status to available$/, fn state ->
    click({:id, "Available-radio-button"})
    {:ok, state}
  end

  and_ ~r/^I change my status to off-duty$/, fn state ->
    click({:id, "Off-radio-button"})
    {:ok, state}
  end

  when_ ~r/^I click update information button as courier$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see my updated courier name "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    name_elem = find_element(:id, "name")
    name_text = inner_text(name_elem)
    assert name == name_text
    {:ok, state}
  end

  then_ ~r/^I should see my courier name unchanged "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    name_element = find_element(:id, "name")
    name_text = inner_text(name_element)
    assert name == name_text
    {:ok, state}
  end

  then_ ~r/^I should see my updated status as available$/, fn state ->
    status = inner_text(find_element(:id, "status"))
    assert status == "Available"
    {:ok, state}
  end

  then_ ~r/^I should see my updated status as off-duty$/, fn state ->
    status = inner_text(find_element(:id, "status"))
    assert status == "Off duty"
    {:ok, state}
  end

  #########################################################################################################
  #
  # Restaurant
  #
  #########################################################################################################

  given_ ~r/^Restaurant with email "(?<email>[^"]+)" and password "(?<password>[^"]+)" is logged in$/, fn state, %{email: email, password: password} ->
    navigate_to "/sessions/new"
    fill_field({:id, "email"}, email)
    fill_field({:id, "password"}, password)
    click({:id, "restaurant-radio"})
    click({:id, "submit_button"})
    {:ok, state}
  end

  and_ ~r/^I open my profile page as restaurant$/, fn state ->
    navigate_to "/restaurant/profile"
    {:ok, state}
  end

  and_ ~r/^I click edit information button as restaurant$/, fn state ->
    click({:id, "edit-info-button"})
    {:ok, state}
  end

  and_ ~r/^I change my existing name as restaurant to "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    fill_field({:id, "name"}, name)
    {:ok, state}
  end

  and_ ~r/^I change my closing hour as restaurant to "(?<closes_at>[^"]+)"$/, fn state, %{closes_at: closes_at} ->
    fill_field({:id, "closes_at"}, closes_at)
    {:ok, state}
  end

  when_ ~r/^I click update information button as restaurant$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see my updated restaurant closing hour "(?<closes_at>[^"]+)"$/, fn state, %{closes_at: closes_at} ->
    name_elem = find_element(:id, "closes_at")
    name_text = inner_text(name_elem)
    assert closes_at == name_text
    {:ok, state}
  end

  then_ ~r/^I should see my restaurant name unchanged "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    name_element = find_element(:id, "name")
    name_text = inner_text(name_element)
    assert name == name_text
    {:ok, state}
  end

  #########################################################################################################
  #
  #
  # Add menu item
  #
  #
  #########################################################################################################

  and_ ~r/^I open my menu$/, fn state ->
    click({:id, "menu"})
    {:ok, state}
  end

  and_ ~r/^I click add new item button$/, fn state ->
    if element?(:id, "add-very-new-item") do
      click({:id, "add-very-new-item"})
    else
      click({:id, "add-new-item"})
    end
    {:ok, state}
  end

  and_ ~r/^I enter food details as name "(?<name>[^"]+)", description "(?<description>[^"]+)", category "(?<category>[^"]+)", and price "(?<price>[^"]+)"$/, fn state, %{name: name, description: description, category: category, price: price} ->
    fill_field({:id, "name"}, name)
    fill_field({:id, "description"}, description)
    fill_field({:id, "category"}, category)
    fill_field({:id, "price"}, price)
    {:ok, state}
  end

  and_ ~r/^I enter food details as name "(?<name>[^"]+)", description "(?<description>[^"]+)", category "(?<category>[^"]+)"$/, fn state, %{name: name, description: description, category: category} ->
    fill_field({:id, "name"}, name)
    fill_field({:id, "description"}, description)
    fill_field({:id, "category"}, category)
    {:ok, state}
  end

  when_ ~r/^I click submit$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for adding menu item$/, fn state ->
    assert visible_in_page? ~r/Added Item!/
    {:ok, state}
  end

  then_ ~r/^I should see error message for adding menu item$/, fn state ->
    assert visible_in_page? ~r/Oops! Something went wrong!/
    {:ok, state}
  end

  ##################################
  #
  #  Interactive search
  #
  ##################################

  when_ ~r/^I go to restaurants page$/, fn state ->
    navigate_to "/restaurants"
    {:ok, state}
  end

  then_ ~r/^I should see list of restaurants$/, fn state ->
    assert element?(:class, "content")
    {:ok, state}
  end

  and_ ~r/^I select filter by tag$/, fn state ->
    click({:id, "profile-radio-button"})
    click({:id, "tag-radio-button"})
    {:ok, state}
  end

  and_ ~r/^I select tag I want to filter by is fast food$/, fn state ->
    click({:id, "tag-input-button-1"})
    {:ok, state}
  end

  and_ ~r/^I select tag I want to filter by is vegan$/, fn state ->
    click({:id, "tag-input-button-2"})
    {:ok, state}
  end

  and_ ~r/^I select show all$/, fn state ->
    click({:id, "all-radio-button"})
    {:ok, state}
  end

  when_ ~r/^I click apply filters$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see list of restaurants filtered by tag$/, fn state ->
    assert !element?(:class, "content")
    {:ok, state}
  end

  ##################################
  #
  #  Order
  #
  ##################################

  and_ ~r/^I select restaurant$/, fn state ->
    click({:class, "restaurant-image"})
    {:ok, state}
  end

  and_ ~r/^I go to menu$/, fn state ->
    click({:id, "profile-radio-button"})
    click({:id, "submit_button"})
    {:ok, state}
  end

  and_ ~r/^I enter my order$/, fn state ->
    fill_field({:class, "item-amount"}, 1)
    {:ok, state}
  end

  when_ ~r/^I click submit button$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for placing order$/, fn state ->
    assert visible_in_page? ~r/Order created succesfully. Money withdrawed from card balance./
    {:ok, state}
  end

  then_ ~r/^I should see error message for placing order$/, fn state ->
    assert visible_in_page? ~r/You have an existing order. Please, finish it first./
    {:ok, state}
  end

  ##################################
  #
  #  Report
  #
  ##################################

  # Customer
  when_ ~r/^I go to report page as customer$/, fn state ->
    navigate_to "/customer/my-orders"
    Process.sleep(1000)
    {:ok, state}
  end

  then_ ~r/^I should see my orders as customer$/, fn state ->
    assert visible_in_page? ~r/Completed Orders/
    {:ok, state}
  end

  # Restaurant
  when_ ~r/^I go to report page as restaurant$/, fn state ->
    navigate_to "/restaurant/restaurant-orders"
    {:ok, state}
  end

  then_ ~r/^I should see my orders as restaurant$/, fn state ->
    assert visible_in_page? ~r/Ongoing Orders List/
    {:ok, state}
  end

  # Courier
  when_ ~r/^I go to report page as courier$/, fn state ->
    navigate_to "/courier/my-orders"
    {:ok, state}
  end

  then_ ~r/^I should see my orders as courier$/, fn state ->
    assert visible_in_page? ~r/Completed Orders/
    {:ok, state}
  end

  ##################################
  #
  #  Restaurant Order actions
  #
  ##################################

  and_ ~r/^I go to orders page$/, fn state ->
    navigate_to "/restaurant/restaurant-orders"
    {:ok, state}
  end

  and_ ~r/^I enter time "(?<time>[^"]+)" for pending order$/, fn state, %{time: time} ->
    fill_field({:id, "time"}, time)
    {:ok, state}
  end

  when_ ~r/^I confirm order$/, fn state ->
    click({:id, "confirm_order"})
    {:ok, state}
  end

  then_ ~r/^Order status becomes in process$/, fn state ->
    status_info = inner_text(find_element(:id, "status-info"))
    assert status_info == "in-process"
    {:ok, state}
  end

  given_ ~r/^There's estimated time for in-process order$/, fn state ->
    estimated_time_original = inner_text(find_element(:id, "estimated-time"))
    {:ok, state |> Map.put(:estimateTime, estimated_time_original)}
  end

  and_ ~r/^I enter time "(?<time>[^"]+)" for in-process order$/, fn state, %{time: time} ->
    fill_field({:id, "time"}, time)
    {:ok, state}
  end

  when_ ~r/^I click update time button$/, fn state ->
    click({:id, "confirm_order"})
    {:ok, state}
  end

  then_ ~r/Estimated time should be different from original$/, fn state ->
    estimated_time_new = inner_text(find_element(:id, "estimated-time"))
    assert state[:estimatedTime] != estimated_time_new
    {:ok, state}
  end

  when_ ~r/^I mark in-process order as prepared$/, fn state ->
    click({:id, "order_prepared"})
    {:ok, state}
  end

  then_ ~r/^Order status becomes prepared$/, fn state ->
    status_info = inner_text(find_element(:id, "status-info"))
    assert status_info == "prepared"
    {:ok, state}
  end

  and_ ~r/^I click more actions button$/, fn state ->
    click({:id, "more-actions-button"})
    {:ok, state}
  end

  when_ ~r/^I click cancel order button$/, fn state ->
    click({:id, "order_prepared"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for order cancellation$/, fn state ->
    assert visible_in_page? ~r/Order has been successfully cancelled!/
    {:ok, state}
  end

  # Order - Customer, Restaurant, Courier
  and_ ~r/^I go to available orders page$/, fn state ->
    navigate_to "/courier/available-orders/address-selection"
    click({:id, "test_input"})
    {:ok, state}
  end

  and_ ~r/^I click view available orders$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  and_ ~r/^I accept order$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  when_ ~r/^I reject order$/, fn state ->
    click({:id, "reject_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for rejected order$/, fn state ->
    assert visible_in_page? ~r/You rejected available order. It won't be visible to you anymore!/
    {:ok, state}
  end

  and_ ~r/^I go to my orders page$/, fn state ->
    navigate_to "/courier/my-orders"
    {:ok, state}
  end

  when_ ~r/^I click complete order$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for completed order$/, fn state ->
    assert visible_in_page? ~r/You have successfully completed the order and your status was changed to Available!/
    {:ok, state}
  end

  #####################
  #
  # Restaurant update menu
  #
  #####################

  # edit
  and_ ~r/^I click edit button$/, fn state ->
    click({:id, "edit-button"})
    {:ok, state}
  end

  and_ ~r/^I update name to "(?<name>[^"]+)"$/, fn state, %{name: name} ->
    fill_field({:id, "name"}, name)
    {:ok, state}
  end

  when_ ~r/^I click update information$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see updated name in menu items list$/, fn state ->
    Process.sleep(1000)
    assert visible_in_page? ~r/Updated name/
    {:ok, state}
  end

  then_ ~r/^I should see error message for editing item$/, fn state ->
    Process.sleep(1000)
    assert visible_in_page? ~r/You can't update item information while having an ongoing order! Please try again later./
    {:ok, state}
  end

  ###
  # Review
  ###

  and_ ~r/^I click review page button$/, fn state ->
    click({:id, "review_page_button"})
    {:ok, state}
  end

  and_ ~r/^I fill out review body with "(?<body>[^"]+)"$/, fn state, %{body: body} ->
    fill_field({:id, "review_body"}, body)
    {:ok, state}
  end

  when_ ~r/^I click submit review button$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should see success message for submitted review$/, fn state ->
    assert visible_in_page? ~r/Your review has been successfully saved/
    {:ok, state}
  end
end
