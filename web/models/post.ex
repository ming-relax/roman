defmodule Roman.Post do
  use Roman.Web, :model

  schema "posts" do
    field :content, :string
    belongs_to :topic, Roman.Topic
    belongs_to :user, Roman.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end
