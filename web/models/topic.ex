defmodule Roman.Topic do
  use Roman.Web, :model
  alias Roman.User

  schema "topics" do
    field :title, :string
    field :content, :string

    field :last_post_user_id, :integer
    field :last_posted_at, Ecto.DateTime
    field :posts_count, :integer

    belongs_to :user, Roman.User
    has_many :posts, Roman.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content])
    |> validate_required([:title, :content])
  end

end
