defmodule Roman.Repo.Migrations.AddUniqueIndexToUsers do
  use Ecto.Migration

  def change do
    create index(:users, :name, unique: true)
  end
end
