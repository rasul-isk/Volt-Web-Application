Feature: User registration
  As a user without an account
  I want to register on the system

  Scenario: Registering as a courier - success
    And I open courier registration page
    And My courier name is "Bravo"
    And I enter my courier name
    And My courier email is "bravo@mail.com"
    And I enter my courier email
    And I want my courier password to be "bravo123"
    And I enter my courier password
    When I submit the courier registration form
    Then I should see success message for courier registration

  Scenario: Registering as a courier - fail (existing email)
  Given The following courier
          | name         | email	        |
          | Bravo        | bravo@mail.com |
    And I open courier registration page
    And My courier name is "Bravo"
    And I enter my courier name
    And My courier email is "bravo@mail.com"
    And I enter my courier email
    And I want my courier password to be "bravo123"
    And I enter my courier password
    When I submit the courier registration form
    Then I should see error message for courier registration

  Scenario: Registering as a restaurant - success
    And I open restaurant registration page
    And My restaurant name is "Meatadore"
    And I enter my restaurant name
    And My restaurant email is "meatadore@mail.com"
    And I enter my restaurant email
    And I want my restaurant password to be "mypass"
    And I enter my restaurant password
    And I choose my restaurant category
    And I choose my tags
    And My restaurant address is "Ulikooli 18, 50090, Tartu"
    And I enter my restaurant address
    And My opening hour is "10:00 AM"
    And I enter my opening hour
    And My closing hour is "19:00 PM"
    And I enter my closing hour
    And My restaurant description is "good restaurant"
    And I enter my restaurant description
    When I submit the restaurant registration form
    Then I should see success message for restaurant registration

  Scenario: Registering as a restaurant - fail (existing email)
    Given The following restaurant
          | name      | email	             |
          | Meatadore | meatadore@mail.com |
    And I open restaurant registration page
    And My restaurant name is "Meatadore"
    And I enter my restaurant name
    And My restaurant email is "meatadore@mail.com"
    And I enter my restaurant email
    And I want my restaurant password to be "mypass"
    And I enter my restaurant password
    And I choose my restaurant category
    And I choose my tags
    And My restaurant address is "Ulikooli 18, 50090, Tartu"
    And I enter my restaurant address
    And My opening hour is "10:00 AM"
    And I enter my opening hour
    And My closing hour is "19:00 PM"
    And I enter my closing hour
    And My restaurant description is "good restaurant"
    And I enter my restaurant description
    When I submit the restaurant registration form
    Then I should see error message for restaurant registration

  Scenario: Registering as a customer - success
    And I open customer registration page
    And My customer name is "Max"
    And I enter my customer name
    And My customer email is "max@gmail.com"
    And I enter my customer email
    And I want my customer password to be "mypassword"
    And I enter my customer password
    And My date of birth is "1990-12-11"
    And I enter my date of birth
    And My address is "Ulikooli 18, 50090, Tartu"
    And I enter my address
    And My card number is "4169741232138822"
    And I enter my card number
    When I submit the customer registration form
    Then I should see success message for customer registration

  Scenario: Registering as a customer - fail (existing email)
    Given The following customer
          | name      | email	             |
          | Max | max@gmail.com |
    And I open customer registration page
    And My customer name is "Max"
    And I enter my customer name
    And My customer email is "max@gmail.com"
    And I enter my customer email
    And I want my customer password to be "mypassword"
    And I enter my customer password
    And My date of birth is "1990-12-11"
    And I enter my date of birth
    And My address is "Ulikooli 18, 50090, Tartu"
    And I enter my address
    And My card number is "4169741232138822"
    And I enter my card number
    When I submit the customer registration form
    Then I should see error message for customer registration

# Feature: Reset password
#   As a user with an existing account,
#   I want to be able to reset my password,
#   so that I can use different password

#   Scenario: Resetting password - success
#     Given the following user with password
#           | name  | email          | crypted_password                                             | dateofbirth | address       | cardnumber | role     | password_reset_token | password_reset_sent_at  |
#           | Salam | salam@123.com  | $2b$12$hwbm.Vzf5q6hIa6PuZBc1.lzfqdEra3DxFTWHflPT0QqWG7MkhcO. | 1212-12-12  | salam@123.com | 4169741232138822   | Customer |                      |                         |
#     And I open reset password page
#     And My existing email is "salam@123.com"
#     And I input my email
#     And I click send password reset email button
#     And I open inbox
#     And I click on the link to open reset password page
#     And I want my new password to be "new_pass"
#     And I enter my new password
#     When I click save
#     Then I should see success message for password reset

#   Scenario: Resetting password - success
#     And I open reset password page
#     And My existing email is "nonexistent@mail.com"
#     And I input my email
#     When I click send password reset email button
#     Then I should see error message for password reset

Feature: User login
  As a user with an existing account,
  I want to be able to login using my email, password, and user type,
  So that I can access service behind login screen

  Scenario: Customer login - success
    Given The following existing customer
          | name | email | crypted_password | dateofbirth | address | cardnumber | role | password_reset_token | password_reset_sent_at |
          | Eminem | eminem@rap.com | $2b$12$cZ1Z//0ajWaj5AA/oJK2SegzSN4pbCUXPzgJ9gwFjQUjw13h9hQZu | 2000-02-02 | Raatuse 22, 51009, Tartu | 4169741232138822 | Customer | | |
    And I open login page as customer
    And My existing customer email is "eminem@rap.com"
    And I enter my existing customer email
    And My existing customer password is "eminem@rap.com"
    And I enter my existing customer password
    And I choose customer role
    When I click login button as customer
    Then I should see welcome message for customer login

  Scenario: Customer login - fail (wrong password)
    And I open login page as customer
    And My existing customer email is "eminem@rap.com"
    And I enter my existing customer email
    And My existing customer password is "wrong"
    And I enter my existing customer password
    And I choose customer role
    When I click login button as customer
    Then I should see error message for customer login

  Scenario: Courier login - success
    Given The following existing courier
      | name   | email              | crypted_password                                             | revenue | likes | dislikes | is_available | role    |  password_reset_token | password_reset_sent_at |
      | Eminem | eminem@courier.com | $2b$12$xSoECeZklivgUpPve3gpdeK.2u2RZxzFyoG3TjNS5g9Kh2.5EhWEu | 0       | 0     | 0        | true         | Courier |                       |                        |
    And I open login page as courier
    And My existing courier email is "eminem@courier.com"
    And I enter my existing courier email
    And My existing courier password is "eminem@courier.com"
    And I enter my existing courier password
    And I choose courier role
    When I click login button as courier
    Then I should see welcome message for courier login

  Scenario: Courier login - fail (wrong password)
    And I open login page as courier
    And My existing courier email is "eminem@courier.com"
    And I enter my existing courier email
    And My existing courier password is "wrong"
    And I enter my existing courier password
    And I choose courier role
    When I click login button as courier
    Then I should see error message for courier login

  Scenario: Restaurant login - success
    Given The following existing restaurant
            | name      | email              | crypted_password                                             | address                   | opens_at | closes_at | likes | dislikes | role       | password_reset_token | password_reset_sent_at |
            | Sushi Room| sushiroom@mail.com | $2b$12$wqZzPPkyr1phP/ik7jBp5ecAm.pqux8mFFwCLMHaGMMz6vpbKBV4u | Ulikooli 18, 50090, Tartu | 10:00    | 19:00     | 0     | 0        | Restaurant |                      |                        |
    And I open login page as restaurant
    And My existing restaurant email is "sushiroom@mail.com"
    And I enter my existing restaurant email
    And My existing restaurant password is "mypass"
    And I enter my existing restaurant password
    And I choose restaurant role
    When I click login button as restaurant
    Then I should see welcome message for restaurant login

  Scenario: Restaurant login - fail (wrong password)
    And I open login page as restaurant
    And My existing restaurant email is "sushiroom@mail.com"
    And I enter my existing restaurant email
    And My existing restaurant password is "wrong"
    And I enter my existing restaurant password
    And I choose restaurant role
    When I click login button as restaurant
    Then I should see error message for restaurant login

Feature: Update profile
  As a user with an existing account,
  I want to be able to update my profile,
  So that I can change my details after signing up

  Scenario: Customer update profile - success
    Given Customer with email "eminem@rap.com" and password "eminem@rap.com" is logged in
    And I open my profile page as customer
    And I click edit information button as customer
    And I change my existing cardnumber as customer to "1111222233334445"
    When I click update information button as customer
    Then I should see updated customer credit card number "1111222233334445"

  Scenario: Customer update profile - fail (blank name)
    Given Customer with email "eminem@rap.com" and password "eminem@rap.com" is logged in
    And I open my profile page as customer
    And I click edit information button as customer
    And I change my existing name as customer to " "
    When I click update information button as customer
    Then I should see my customer name unchanged "Eminem"

  Scenario: Courier update profile - success
    Given Courier with email "bravo@mail.com" and password "bravo123" is logged in
    And I open my profile page as courier
    And I click edit information button as courier
    And I change my existing name as courier to "Bravissimo"
    When I click update information button as courier
    Then I should see my updated courier name "Bravissimo"

  Scenario: Courier update profile - fail (blank name)
    Given Courier with email "bravo@mail.com" and password "bravo123" is logged in
    And I open my profile page as courier
    And I click edit information button as courier
    And I change my existing name as courier to " "
    When I click update information button as courier
    Then I should see my courier name unchanged "Bravissimo"

  Scenario: Restaurant update profile - success
    Given Restaurant with email "meatadore@mail.com" and password "mypass" is logged in
    And I open my profile page as restaurant
    And I click edit information button as restaurant
    And I change my closing hour as restaurant to "15:00"
    When I click update information button as restaurant
    Then I should see my updated restaurant closing hour "15:00"

  Scenario: Restaurant update profile - fail (blank name)
    Given Restaurant with email "meatadore@mail.com" and password "mypass" is logged in
    And I open my profile page as restaurant
    And I click edit information button as restaurant
    And I change my existing name as restaurant to " "
    When I click update information button as restaurant
    Then I should see my restaurant name unchanged "Meatadore"

Feature: Add menu item

  Scenario: Add menu item - success
    Given Restaurant with email "meatadore@mail.com" and password "mypass" is logged in
    And I open my menu
    And I click add new item button
    And I enter food details as name "burger", description "regular burger", category "burger", and price "1.99"
    When I click submit
    Then I should see success message for adding menu item

  Scenario: Add menu item - fail (no price)
    Given Restaurant with email "meatadore@mail.com" and password "mypass" is logged in
    And I open my menu
    And I click add new item button
    And I enter food details as name "burger", description "regular burger", category "burger"
    When I click submit
    Then I should see error message for adding menu item

Feature: Interactive search

  Scenario: Restaurants List all
    Given Customer with email "eminem@rap.com" and password "eminem@rap.com" is logged in
    When I go to restaurants page
    Then I should see list of restaurants

  Scenario: Restaurants filter by tag (yes result)
    Given Customer with email "eminem@rap.com" and password "eminem@rap.com" is logged in
    And I go to restaurants page
    And I select filter by tag
    And I select tag I want to filter by is fast food
    And I select show all
    When I click apply filters
    Then I should see list of restaurants filtered by tag

Feature: Ordering - Customer

  # this order is later cancelled. therefore, we wrote same test below (line 338) so that there's valid order in the database
  Scenario: Placing Order as Customer - success
    Given Customer with email "eminem@rap.com" and password "eminem@rap.com" is logged in
    And I go to restaurants page
    And I select restaurant
    And I go to menu
    And I enter my order
    When I click submit button
    Then I should see success message for placing order

  Scenario: Placing Order as Customer - fail (existing order)
    Given Customer with email "eminem@rap.com" and password "eminem@rap.com" is logged in
    And I go to restaurants page
    When I select restaurant
    Then I should see error message for placing order

Feature: Restaurant order actions

  Scenario: Viewing and accepting pending order
    Given Restaurant with email "restaurant2@mail.ru" and password "restaurant2@mail.ru" is logged in
    And I go to orders page
    And I enter time "10" for pending order
    When I confirm order
    Then Order status becomes in process

  Scenario: Viewing and changing order time
    Given There's estimated time for in-process order
    And I enter time "-2" for in-process order
    When I click update time button
    Then Estimated time should be different from original
  
  Scenario: Viewing and completing in process order
    When I mark in-process order as prepared
    Then Order status becomes prepared

  Scenario: Cancelling order
    And I click more actions button
    When I click cancel order button
    Then I should see success message for order cancellation

Feature: Courier status change

  Scenario: Changing off-duty to available
    Given Courier with email "bravo@mail.com" and password "bravo123" is logged in
    And I open my profile page as courier
    And I click edit information button as courier
    And I change my status to available
    When I click update information button as courier
    Then I should see my updated status as available

  Scenario: Changing available to off-duty
    Given Courier with email "bravo@mail.com" and password "bravo123" is logged in
    And I open my profile page as courier
    And I click edit information button as courier
    And I change my status to off-duty
    When I click update information button as courier
    Then I should see my updated status as off-duty

Feature: Order Accepted - Customer, Restaurant, Courier

  Scenario: Customer places order
    Given Customer with email "max@gmail.com" and password "mypassword" is logged in
    And I go to restaurants page
    And I select restaurant
    And I go to menu
    And I enter my order
    When I click submit button
    Then I should see success message for placing order

  Scenario: Restaurant accepts and prepares order
    Given Restaurant with email "restaurant2@mail.ru" and password "restaurant2@mail.ru" is logged in
    And I go to orders page
    And I enter time "1" for pending order
    And I confirm order
    And Order status becomes in process
    And I mark in-process order as prepared
    And Order status becomes prepared
  
  Scenario: Courier picks up order and delivers
    Given Courier with email "courier2@mail.ru" and password "courier2@mail.ru" is logged in
    And I go to available orders page
    And I click view available orders
    And I accept order
    And I go to my orders page
    When I click complete order
    Then I should see success message for completed order

Feature: Order Rejected - Customer, Restaurant, Courier

  Scenario: Customer places order to be rejected
    Given Customer with email "customer1@mail.ru" and password "customer1@mail.ru" is logged in
    And I go to restaurants page
    And I select restaurant
    And I go to menu
    And I enter my order
    When I click submit button
    Then I should see success message for placing order

  Scenario: Restaurant accepts and prepares order to be rejected
    Given Restaurant with email "restaurant2@mail.ru" and password "restaurant2@mail.ru" is logged in
    And I go to orders page
    And I enter time "1" for pending order
    And I confirm order
    And Order status becomes in process
    And I mark in-process order as prepared
    And Order status becomes prepared
  
  Scenario: Courier picks up order and delivers to be rejected
    Given Courier with email "courier2@mail.ru" and password "courier2@mail.ru" is logged in
    And I go to available orders page
    And I click view available orders
    When I reject order
    Then I should see success message for rejected order


Feature: Report

  Scenario: Customer report
    Given Customer with email "max@gmail.com" and password "mypassword" is logged in
    When I go to report page as customer
    Then I should see my orders as customer

  Scenario: Restaurant report
    Given Restaurant with email "sushiroom@mail.com" and password "mypass" is logged in
    When I go to report page as restaurant
    Then I should see my orders as restaurant

  Scenario: Courier report
    Given Courier with email "courier2@mail.ru" and password "courier2@mail.ru" is logged in
    When I go to report page as courier
    Then I should see my orders as courier

Feature: Restaurant update menu
  
  Scenario: Edit menu item
  Given Restaurant with email "restaurant1@mail.ru" and password "restaurant1@mail.ru" is logged in
  And I open my menu
  And I click edit button
  And I update name to "Updated name"
  When I click update information
  Then I should see updated name in menu items list

  Scenario: Edit menu item - fail (ongoing order)
  Given Restaurant with email "restaurant2@mail.ru" and password "restaurant2@mail.ru" is logged in
  And I open my menu
  And I click edit button
  And I update name to "Updated name"
  When I click update information
  Then I should see error message for editing item
  # You can't update item information while having an ongoing order! Please try again later.

Feature: Review delivery
  Scenario: Customer reviews delivery
    Given Customer with email "max@gmail.com" and password "mypassword" is logged in
    And I go to report page as customer
    And I click review page button
    And I fill out review body with "bad"
    When I click submit review button
    Then I should see success message for submitted review