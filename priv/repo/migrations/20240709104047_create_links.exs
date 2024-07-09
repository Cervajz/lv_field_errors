defmodule LvFieldErrors.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :title, :text, null: false
      add :url, :string, null: false
      add :note, :text

      timestamps(type: :utc_datetime)
    end
  end
end
