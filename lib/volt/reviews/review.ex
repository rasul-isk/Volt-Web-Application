defmodule Volt.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Accounts.Customer
  alias Volt.Accounts.Restaurant
  alias Volt.Orders.Order


  schema "reviews" do
    belongs_to(:customers, Customer, foreign_key: :customer_id)
    belongs_to(:restaurants, Restaurant, foreign_key: :restaurant_id)
    belongs_to(:orders, Order, foreign_key: :order_id)
    field :body, :string
    field :rating, :integer

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:customer_id, :restaurant_id, :order_id, :rating, :body])
    |> validate_required([:customer_id, :restaurant_id, :order_id, :rating, :body])
  end

    def create(changeset, repo) do
    changeset
    |> repo.insert()
  end
end
