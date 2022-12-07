defmodule Volt.Repo.Migrations.CreateCouriers do
  use Ecto.Migration

  def change do
    create table(:couriers) do
      add :name, :string
      add :email, :string
      add :crypted_password, :string
      add :revenue, :float
      add :likes, :integer
      add :dislikes, :integer
      add :status, :string, default: "Off duty"
      add :role, :string
      add :rejectedOrders, :string
      add :password_reset_token, :string, default: nil
      add :password_reset_sent_at, :naive_datetime, default: nil


      timestamps()
    end

    create unique_index(:couriers, [:email])
  end
end
