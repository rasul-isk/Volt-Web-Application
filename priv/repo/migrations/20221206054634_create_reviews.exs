defmodule Volt.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :customer_id, references(:customers, on_delete: :delete_all)
      add :restaurant_id, references(:restaurants, on_delete: :delete_all)
      add :order_id, references(:orders, on_delete: :nothing)
      add :rating, :integer
      add :body, :text

      timestamps()
    end

    create index(:reviews, [:customer_id, :restaurant_id, :order_id, :rating, :body])
  end
end
