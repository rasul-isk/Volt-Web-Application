defmodule Volt.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Accounts.Customer
  alias Volt.Accounts.Restaurant
  alias Volt.Accounts.Courier
  alias Volt.OrderItems.OrderItem
  alias Volt.Reviews.Review

  schema "orders" do
    belongs_to(:customers, Customer, foreign_key: :customer_id)
    belongs_to(:restaurants, Restaurant, foreign_key: :restaurant_id)
    belongs_to(:couriers, Courier, foreign_key: :courier_id)
    field :restaurantFee, :float, default: 0.0
    field :deliveryFee, :float, default: 0.0
    field :addressFrom, :string, default: "notDefined"
    field :addressTo, :string, default: "notDefined"
    field :initialStatus, :string, default: "pending"
    field :isCancelled, :boolean, default: false
    field :orderOverallStatus, :string, default: "submitted"
    field :orderRestaurantStatus, :string, default: "pending"
    field :restaurantPreparationTime, :string, default: "no-time"
    field :deliveryTime, :string, default: "no-time"
    field :orderTimeMade, :string, default: "no-time"
    field :isScheduled, :boolean, default: false
    field :rejectMessage, :string, default: "noMessage"

    has_many(:order_items, OrderItem)
    has_one(:reviews, Review)
    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:customer_id, :restaurant_id, :courier_id, :restaurantFee, :deliveryFee, :addressFrom, :addressTo, :initialStatus, :isCancelled, :orderOverallStatus, :orderRestaurantStatus,:restaurantPreparationTime, :deliveryTime, :orderTimeMade, :isScheduled, :rejectMessage])
    |> validate_required([:customer_id, :restaurant_id, :courier_id, :restaurantFee, :deliveryFee, :addressFrom, :addressTo, :initialStatus, :isCancelled, :orderOverallStatus, :orderRestaurantStatus,:restaurantPreparationTime, :deliveryTime, :orderTimeMade, :isScheduled, :rejectMessage])
  end

  def time_changeset(order, attrs) do
    order
    |> cast(attrs, [:initialStatus, :isCancelled, :restaurantPreparationTime, :orderRestaurantStatus, :rejectMessage])
    |> validate_required([:initialStatus, :isCancelled, :restaurantPreparationTime, :orderRestaurantStatus, :rejectMessage])
  end

  def create(changeset, repo) do
    changeset
    |> repo.insert()
  end


end
