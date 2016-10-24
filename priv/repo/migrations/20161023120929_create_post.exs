defmodule Roman.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :content, :string
      add :topic_id, references(:topics, on_delete: :nothing)

      timestamps()
    end
    create index(:posts, [:topic_id])

  end
end
