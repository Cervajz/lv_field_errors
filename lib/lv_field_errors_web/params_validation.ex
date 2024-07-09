defmodule LvFieldErrorsWeb.ParamsNormalization do
  @moduledoc false
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, apply_action: 2]
  alias Ecto.Changeset

  @spec normalize_params(map(), list()) :: {:ok, map()} | {:error, Changeset.t()}
  def normalize_params(params, input_schema) do
    params
    |> cast_params(input_schema)
    |> validate(input_schema)
    |> apply_action(:insert)
  end

  @spec input_schema_to_changeset(list()) :: Changeset.t()
  def input_schema_to_changeset(input_schema) do
    cast_params(%{}, input_schema)
  end

  defp cast_params(params, input_schema) do
    allowed_params = Keyword.keys(input_schema)

    types =
      Map.new(allowed_params, fn key ->
        [type, _] = Keyword.get(input_schema, key)
        {key, type}
      end)

    cast({%{}, types}, params, allowed_params)
  end

  defp validate(changeset, input_schema) do
    allowed_params = Keyword.keys(input_schema)

    required_params =
      Enum.filter(allowed_params, fn key ->
        [_, required] = Keyword.get(input_schema, key)
        required == {:required, true}
      end)

    validate_required(changeset, required_params)
  end
end
