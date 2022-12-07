defmodule Volt.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :name, :string
      add :email, :string
      add :crypted_password, :string
      add :dateofbirth, :date
      add :address, :string
      add :cardnumber, :string
      add :role, :string

      add :balance, :float, default: 300.0

      add :password_reset_token, :string, default: nil
      add :password_reset_sent_at, :naive_datetime, default: nil


      timestamps()
    end

    create unique_index(:customers, [:email])
  end
end
