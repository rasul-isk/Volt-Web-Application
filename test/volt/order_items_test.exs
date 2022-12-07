defmodule Volt.OrderItemsTest do
  use Volt.DataCase

  alias Volt.OrderItems

  # describe "order_items" do
  #   alias Volt.OrderItems.OrderItem

  #   import Volt.OrderItemsFixtures

  #   @invalid_attrs %{quantity: nil, status: nil}

  #   test "list_order_items/0 returns all order_items" do
  #     order_item = order_item_fixture()
  #     assert OrderItems.list_order_items() == [order_item]
  #   end

  #   test "get_order_item!/1 returns the order_item with given id" do
  #     order_item = order_item_fixture()
  #     assert OrderItems.get_order_item!(order_item.id) == order_item
  #   end

  #   test "create_order_item/1 with valid data creates a order_item" do
  #     valid_attrs = %{quantity: 42, status: "some status"}

  #     assert {:ok, %OrderItem{} = order_item} = OrderItems.create_order_item(valid_attrs)
  #     assert order_item.quantity == 42
  #     assert order_item.status == "some status"
  #   end

  #   test "create_order_item/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = OrderItems.create_order_item(@invalid_attrs)
  #   end

  #   test "update_order_item/2 with valid data updates the order_item" do
  #     order_item = order_item_fixture()
  #     update_attrs = %{quantity: 43, status: "some updated status"}

  #     assert {:ok, %OrderItem{} = order_item} = OrderItems.update_order_item(order_item, update_attrs)
  #     assert order_item.quantity == 43
  #     assert order_item.status == "some updated status"
  #   end

  #   test "update_order_item/2 with invalid data returns error changeset" do
  #     order_item = order_item_fixture()
  #     assert {:error, %Ecto.Changeset{}} = OrderItems.update_order_item(order_item, @invalid_attrs)
  #     assert order_item == OrderItems.get_order_item!(order_item.id)
  #   end

  #   test "delete_order_item/1 deletes the order_item" do
  #     order_item = order_item_fixture()
  #     assert {:ok, %OrderItem{}} = OrderItems.delete_order_item(order_item)
  #     assert_raise Ecto.NoResultsError, fn -> OrderItems.get_order_item!(order_item.id) end
  #   end

  #   test "change_order_item/1 returns a order_item changeset" do
  #     order_item = order_item_fixture()
  #     assert %Ecto.Changeset{} = OrderItems.change_order_item(order_item)
  #   end
  # end
end
