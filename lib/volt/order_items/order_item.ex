defmodule Volt.OrderItems.OrderItem do
  import Ecto.Query
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Items.Item
  alias Volt.Orders.Order
  alias Volt.Repo

  schema "order_items" do
    belongs_to(:items, Item, foreign_key: :item_id)
    belongs_to(:orders, Order, foreign_key: :order_id)
    field :quantity, :integer
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:item_id, :order_id, :quantity, :status])
    |> validate_required([:item_id, :order_id, :quantity, :status])
  end

  def create(changeset, repo) do
    changeset
    |> repo.insert()
  end

  def count(order_id) do
    query = from x in "order_items",
                      where: x.order_id == ^order_id,
                      select: x.id

    Enum.count(Repo.all(query))
  end

  def get_order_items(order_id) do
    query = from x in "order_items",
                      where: x.order_id == ^order_id,
                      select: x.id
    Repo.all(query)
  end

  def get_order_items_data(order_item_id) do
    query = from x in "order_items",
                      where: x.id == ^order_item_id,
                      select: %{id: x.item_id, quantity: x.quantity}
    Repo.all(query)
  end

  # def get_items() do
  #   Customer
  #   |> preload_join(:orders)
  #   |> preload_join(:customer_items)
  #   |> Repo.all()
  # end

end
