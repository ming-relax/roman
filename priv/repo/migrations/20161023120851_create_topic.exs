defmodule Roman.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :content, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:topics, [:user_id])

  end
end
