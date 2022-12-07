defmodule Volt.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :item_id, references(:items, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :delete_all)
      add :quantity, :integer
      add :status, :string

      timestamps()
    end

    create index(:order_items, [:item_id, :order_id, :quantity, :status])
  end
end
