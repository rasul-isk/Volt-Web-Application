defmodule Volt.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Volt.Carts` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        numberOfItems: 42
      })
      |> Volt.Carts.create_cart()

    cart
  end
end
