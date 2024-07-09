defmodule LvFieldErrorsWeb.LinkLive.FormComponent do
  use LvFieldErrorsWeb, :live_component

  alias LvFieldErrors.Links
  import LvFieldErrorsWeb.ParamsNormalization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage link records in your database.</:subtitle>
      </.header>

      <div class="my-4">
        @form.errors:
        <div class="my-1 text-red-600">
          <%= inspect(@form.errors) %>
        </div>
      </div>

      <.simple_form
        for={@form}
        id="link-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:note]} type="textarea" label="Note" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Link</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{link: link} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Links.change_link(link))
     end)}
  end

  @input_schema [
    title: [:string, required: true],
    url: [:string, required: true],
    note: [:string, required: false]
  ]

  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset =
      case normalize_params(link_params, @input_schema) do
        {:ok, normalized_params} ->
          Links.validate_link(
            socket.assigns.link,
            normalized_params[:title],
            normalized_params[:url],
            normalized_params[:note]
          )

        # Uncomment to have errors working in the form fields again
        # Links.validate_link_cast(socket.assigns.link, normalized_params)

        {:error, changeset} ->
          changeset
      end

    dbg(changeset.params)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"link" => link_params}, socket) do
    save_link(socket, socket.assigns.action, link_params)
  end

  defp save_link(socket, :edit, link_params) do
    with {:ok, normalized_params} <- normalize_params(link_params, @input_schema),
         {:ok, link} <-
           Links.update_link(
             socket.assigns.link,
             normalized_params[:title],
             normalized_params[:url],
             normalized_params[:note]
           ) do
      notify_parent({:saved, link})

      {:noreply,
       socket
       |> put_flash(:info, "Link updated successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_link(socket, :new, link_params) do
    with {:ok, normalized_params} <- normalize_params(link_params, @input_schema),
         {:ok, link} <-
           Links.create_link(
             normalized_params[:title],
             normalized_params[:url],
             normalized_params[:note]
           ) do
      notify_parent({:saved, link})

      {:noreply,
       socket
       |> put_flash(:info, "Link created successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset, action: :validate, as: :link))
  end
end
