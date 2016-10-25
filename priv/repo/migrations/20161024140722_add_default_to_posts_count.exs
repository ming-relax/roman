defmodule Roman.Repo.Migrations.AddDefaultToPostsCount do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      modify :posts_count, :integer, default: 0
    end
  end
end
