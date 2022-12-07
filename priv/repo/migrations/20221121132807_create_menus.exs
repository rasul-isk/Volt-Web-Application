defmodule Volt.Repo.Migrations.CreateMenus do
  use Ecto.Migration

  def change do
    create table(:menus) do
      add :numberOfItems, :integer
      add :restaurant_id, references(:restaurants, on_delete: :delete_all)

      timestamps()
    end

    create index(:menus, [:restaurant_id])
  end
end
