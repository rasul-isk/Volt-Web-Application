defmodule Volt.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Volt.Repo

  alias Volt.Accounts.{Customer, Courier, Restaurant}

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Repo.all(Customer)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

    def update_user(user, attrs) do
    role = String.to_existing_atom("Elixir.Volt.Accounts." <> user.role)

    user
    |> role.changeset(attrs)
    |> Repo.update()
  end

  def get_user(role, id) do
    customer = role == "customer" && Repo.get_by(Customer, id: id)
    courier = role == "courier" && Repo.get_by(Courier, id: id)
    restaurant = role == "restaurant" && Repo.get_by(Restaurant, id: id)

    customer || courier || restaurant
  end

  def get_user_from_token(token) do
    Repo.get_by(Customer, password_reset_token: token)
  end

  def get_user_from_email(email) do
    customer = Repo.get_by(Customer, email: email)
    courier = Repo.get_by(Courier, email: email)
    restaurant = Repo.get_by(Restaurant, email: email)

    customer || courier || restaurant
  end

  def set_token_on_user(user) do
    role = String.to_existing_atom("Elixir.Volt.Accounts." <> user.role)
    attrs = %{"password_reset_token" => SecureRandom.urlsafe_base64(),
    "password_reset_sent_at" => NaiveDateTime.utc_now()}

    user
    |> role.changeset(attrs)
    |> Repo.update!()
  end

  def capitalize_per_word(string) do
    String.split(string)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def valid_token?(token_sent_at) do
    current_time = NaiveDateTime.utc_now()
    Time.diff(current_time, token_sent_at) < 7200
  end

    def get_restaurant!(id), do: Repo.get!(Restaurant, id)

end
