defmodule Volt.Accounts.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Volt.Orders.Order
  alias Volt.Reviews.Review

  schema "customers" do
    field :address, :string
    field :cardnumber, :string
    field :crypted_password, :string
    field :dateofbirth, :date
    field :email, :string
    field :name, :string
    field :role, :string, default: "Customer"

    field :balance, :float, default: 300.0

    field :password_reset_token, :string, default: nil
    field :password_reset_sent_at, :naive_datetime, default: nil
    has_many :orders, Order
    has_many :reviews, Review

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:balance, :name, :email, :crypted_password, :dateofbirth, :address, :cardnumber, :role,:password_reset_token, :password_reset_sent_at])
    |> validate_required([:name, :email, :crypted_password, :dateofbirth, :address, :cardnumber])
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
