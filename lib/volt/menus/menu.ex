defmodule Volt.Menus.Menu do
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Items.Item
  alias Volt.Accounts.Restaurant

  schema "menus" do
    field :numberOfItems, :integer, default: 0
    belongs_to(:restaurants, Restaurant, foreign_key: :restaurant_id)
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(menu, attrs) do
    menu
    |> cast(attrs, [:numberOfItems, :restaurant_id])
    |> validate_required([:numberOfItems, :restaurant_id])
  end

  def create(changeset, repo) do
    changeset
    |> repo.insert()
  end
end
