defmodule Volt.AccountsTest do
  use Volt.DataCase

  alias Volt.Accounts

  describe "customers" do
    alias Volt.Accounts.Customer

    import Volt.AccountsFixtures

    @invalid_attrs %{address: nil, cardnumber: nil, crypted_password: nil, dateofbirth: nil, email: nil, name: nil}

    # test "list_customers/0 returns all customers" do
    #   customer = customer_fixture()
    #   assert Accounts.list_customers() == [customer]
    # end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Accounts.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{address: "some address", cardnumber: "some cardnumber", crypted_password: "some crypted_password", dateofbirth: ~D[2022-11-08], email: "some email", name: "some name"}

      assert {:ok, %Customer{} = customer} = Accounts.create_customer(valid_attrs)
      assert customer.address == "some address"
      assert customer.cardnumber == "some cardnumber"
      assert customer.crypted_password == "some crypted_password"
      assert customer.dateofbirth == ~D[2022-11-08]
      assert customer.email == "some email"
      assert customer.name == "some name"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      update_attrs = %{address: "some updated address", cardnumber: "some updated cardnumber", crypted_password: "some updated crypted_password", dateofbirth: ~D[2022-11-09], email: "some updated email", name: "some updated name"}

      assert {:ok, %Customer{} = customer} = Accounts.update_customer(customer, update_attrs)
      assert customer.address == "some updated address"
      assert customer.cardnumber == "some updated cardnumber"
      assert customer.crypted_password == "some updated crypted_password"
      assert customer.dateofbirth == ~D[2022-11-09]
      assert customer.email == "some updated email"
      assert customer.name == "some updated name"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_customer(customer, @invalid_attrs)
      assert customer == Accounts.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Accounts.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Accounts.change_customer(customer)
    end
  end

end
