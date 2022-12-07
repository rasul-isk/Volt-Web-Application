defmodule Volt.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Volt.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{

      })
      |> Volt.Orders.create_order()

    order
  end
end
