defmodule LvFieldErrors.Links.Link do
  use Ecto.Schema

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          title: String.t() | nil,
          url: String.t() | nil,
          note: String.t() | nil
        }

  schema "links" do
    field :title, :string
    field :url, :string
    field :note, :string

    timestamps(type: :utc_datetime)
  end
end
