defmodule Roman.Repo.Migrations.AddSomeMetaToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :last_post_user_id, references(:users)
      add :last_posted_at, :datetime
      add :posts_count, :integer
    end
  end
end
