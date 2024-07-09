defmodule LvFieldErrors.Links do
  @moduledoc """
  The Links Core.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias LvFieldErrors.Repo

  alias LvFieldErrors.Links.Link

  def list_links do
    Repo.all(Link)
  end

  def get_link!(id), do: Repo.get!(Link, id)

  @spec create_link(String.t(), String.t(), String.t()) ::
          {:ok, Link.t()} | {:error, Changeset.t()}
  def create_link(title, url, note) do
    %Link{}
    |> validate_link(title, url, note)
    |> Repo.insert()
  end

  @spec update_link(Link.t(), String.t(), String.t(), String.t()) ::
          {:ok, Link.t()} | {:error, Changeset.t()}
  def update_link(%Link{} = link, title, url, note) do
    link
    |> validate_link(title, url, note)
    |> Repo.update()
  end

  @spec change_link(Link.t()) :: Changeset.t()
  def change_link(%Link{} = link) do
    change(link, %{})
  end

  @spec validate_link(Link.t(), String.t(), String.t(), String.t()) :: Changeset.t()
  def validate_link(%Link{} = link, title, url, note) do
    link
    |> change(%{title: title, url: url, note: note})
    |> validate_link_data()
  end

  @spec validate_link_cast(Link.t(), map()) :: Changeset.t()
  def validate_link_cast(%Link{} = link, attrs \\ %{}) do
    link
    |> cast(attrs, [:title, :url, :note])
    |> validate_link_data()
  end

  @spec delete_link(Link.t()) :: {:ok, Link.t()} | {:error, Ecto.Changeset.t()}
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  defp validate_link_data(changeset) do
    changeset
    |> validate_required([:title, :url, :note])
    |> validate_length(:title, max: 5)
    |> validate_change(:url, &validate_url/2)
  end

  defp validate_url(field, value) do
    if String.contains?(value, "http") do
      []
    else
      [{field, "is not a valid URL. Must include http"}]
    end
  end
end
