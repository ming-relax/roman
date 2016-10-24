defmodule Roman.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Roman.Repo
  alias Roman.User

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unkown resource type"}

  # plug Guardian.Plug.LoadResource will use this serializer to load resource from the
  # found JWT
  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end