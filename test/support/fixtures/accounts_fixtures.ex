defmodule Volt.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Volt.Accounts` context.
  """

  @doc """
  Generate a unique customer email.
  """
  def unique_customer_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        address: "some address",
        cardnumber: "some cardnumber",
        crypted_password: "some crypted_password",
        dateofbirth: ~D[2022-11-08],
        email: unique_customer_email(),
        name: "some name"
      })
      |> Volt.Accounts.create_customer()

    customer
  end


  # @doc """
  # Generate a customer__order.
  # """
  # def customer__order_fixture(attrs \\ %{}) do
  #   {:ok, customer__order} =
  #     attrs
  #     |> Enum.into(%{
  #       address: "some address",
  #       meal_name: "some meal_name",
  #       restaurant: "some restaurant"
  #     })
  #     |> Volt.Accounts.create_customer__order()

  #   customer__order
  # end

end
