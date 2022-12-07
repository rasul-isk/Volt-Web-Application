defmodule Volt.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :customer_id, references(:customers, on_delete: :delete_all)
      add :restaurant_id, references(:restaurants, on_delete: :delete_all)
      add :courier_id, references(:couriers, on_delete: :delete_all)
      add :restaurantFee, :float
      add :deliveryFee, :float
      add :addressFrom, :string
      add :addressTo, :string
      add :initialStatus, :string
      add :isCancelled, :boolean
      add :orderOverallStatus, :string
      add :orderRestaurantStatus, :string
      add :restaurantPreparationTime, :string
      add :deliveryTime, :string
      add :orderTimeMade, :string
      add :isScheduled, :boolean
      add :rejectMessage, :text
      timestamps()
    end

    create index(:orders, [:customer_id, :restaurant_id, :courier_id, :restaurantFee, :deliveryFee, :addressFrom, :addressTo, :initialStatus, :isCancelled, :orderOverallStatus, :orderRestaurantStatus, :restaurantPreparationTime, :deliveryTime, :orderTimeMade, :isScheduled, :rejectMessage])
  end
end
