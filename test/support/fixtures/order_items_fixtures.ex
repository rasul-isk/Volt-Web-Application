defmodule Volt.OrderItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Volt.OrderItems` context.
  """

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    {:ok, order_item} =
      attrs
      |> Enum.into(%{
        quantity: 42,
        status: "some status"
      })
      |> Volt.OrderItems.create_order_item()

    order_item
  end
end
