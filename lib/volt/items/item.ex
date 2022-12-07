defmodule Volt.Items.Item do
  import Ecto.Query
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Menus.Menu

  schema "items" do
    field :category, :string
    field :description, :string
    field :name, :string
    field :price, :decimal
    belongs_to(:menus, Menu, foreign_key: :menu_id)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :category, :price, :menu_id])
    |> validate_required([:name, :description, :category, :price, :menu_id])
  end

  def get_items_for_order(order_item_id) do
    query = from x in "items",
                      where: x.id == ^order_item_id,
                      select: %{id: x.id, menu_id: x.menu_id, name: x.name, description: x.description, category: x.category}
    Repo.all(query)
  end
end
