defmodule Volt.Accounts.Courier do
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Orders.Order

  schema "couriers" do
    field :email, :string
    field :crypted_password, :string
    field :name, :string
    field :revenue, :float
    field :likes, :integer
    field :dislikes, :integer
    field :status, :string
    field :role, :string, default: "Courier"
    field :rejectedOrders, :string, default: ""
    field :password_reset_token, :string, default: nil
    field :password_reset_sent_at, :naive_datetime, default: nil

    has_many :orders, Order

    timestamps()
  end

  def changeset(courier, attributes) do
    courier
    |> cast(attributes, [:email, :crypted_password, :name, :revenue, :likes, :dislikes, :status, :role, :rejectedOrders, :password_reset_token, :password_reset_sent_at])
    |> validate_required([:email, :crypted_password, :name])
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
