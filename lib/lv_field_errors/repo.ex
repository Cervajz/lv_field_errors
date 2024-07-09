defmodule LvFieldErrors.Repo do
  use Ecto.Repo,
    otp_app: :lv_field_errors,
    adapter: Ecto.Adapters.Postgres
end
