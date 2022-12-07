defmodule Volt.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :name, :string
      add :email, :string
      add :crypted_password, :string
      add :address, :string
      add :opens_at, :string
      add :closes_at, :string
      add :likes, :integer
      add :dislikes, :integer
      add :role, :string

      add :category, :string
      add :tags, :string

      add :description, :string

      add :password_reset_token, :string, default: nil
      add :password_reset_sent_at, :naive_datetime, default: nil


      timestamps()
    end

    create unique_index(:restaurants, [:email])
  end
end
