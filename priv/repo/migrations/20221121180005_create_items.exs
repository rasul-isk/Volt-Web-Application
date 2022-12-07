defmodule Volt.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :description, :text
      add :category, :string
      add :price, :decimal
      add :menu_id, references(:menus, on_delete: :delete_all)

      timestamps()
    end

    create index(:items, [:menu_id])
  end
end
