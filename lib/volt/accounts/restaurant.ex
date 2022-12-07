defmodule Volt.Accounts.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Menus.Menu
  alias Volt.Orders.Order
  alias Volt.Reviews.Review

  schema "restaurants" do
    field :email, :string
    field :crypted_password, :string
    field :name, :string
    field :address, :string
    field :opens_at, :string
    field :closes_at, :string
    field :likes, :integer
    field :dislikes, :integer
    field :role, :string, default: "Restaurant"
    field :description, :string

    field :category, :string
    field :tags, :string

    field :password_reset_token, :string, default: nil
    field :password_reset_sent_at, :naive_datetime, default: nil
    has_one :menus, Menu
    has_many :orders, Order
    has_many :reviews, Review


    timestamps()
  end

  def changeset(restaurant, attributes) do
    restaurant
    |> cast(attributes, [:category,:tags,:description, :email, :crypted_password, :name, :address, :opens_at, :closes_at, :likes, :dislikes,:password_reset_token, :password_reset_sent_at])
    |> validate_required([:email, :crypted_password, :name, :address, :opens_at, :closes_at])
    |> unique_constraint(:email)
  end

  def create(changeset, repo) do
    changeset
    |> put_change(:crypted_password, hashed_password(changeset.params["crypted_password"]))
    |> repo.insert()
  end

  defp hashed_password(password) do
    Bcrypt.hash_pwd_salt(password)
  end
end
