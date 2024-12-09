defmodule AppWeb.UserRegistrationLive do
  use AppWeb, :live_view

  import AppWeb.Component.Button
  import AppWeb.Component.Form
  import AppWeb.Component.Card
  import AppWeb.Component.Label

  alias App.Accounts
  alias App.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.card>
          <.card_header>
            <label class="text-2xl font-bold">Create your account</label>
          </.card_header>

          <.card_content class="space-y-5">
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>
            <.form_item>
              <.form_label error={not Enum.empty?(@form[:email].errors)}>Email</.form_label>
              <.input
                field={@form[:email]}
                type="email"
                placeholder="example@example.com"
                phx-debounce="500"
                required
              />
              <.form_message field={@form[:email]} />
            </.form_item>
            <.form_item>
              <.form_label error={not Enum.empty?(@form[:password].errors)}>Password</.form_label>
              <.input
                field={@form[:password]}
                type="password"
                placeholder="●●●●●●●●"
                phx-debounce="500"
                required
              />
              <.form_message field={@form[:password]} />
            </.form_item>
          </.card_content>

          <.card_content class="flex items-center justify-between">
            <div class="flex items-start">
              <div class="flex items-center h-5">
                <.input id="policy" field={@form[:policy]} type="checkbox" />
              </div>
              <div class="ml-3 text-sm">
                <.label for="policy">By signing up, you are creating an account, and are agreeing to our <.link class="font-semibold text-brand hover:underline">Terms of Service</.link></.label>
              </div>
            </div>
          </.card_content>

          <.card_footer class="flex-col gap-4">
            <.button phx-disable-with="Logging in..." class="w-full">
              Sign in <span aria-hidden="true">→</span>
            </.button>
            <p class="text-sm">
              Already have an account?
              <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
                Sign in
              </.link>
            </p>
          </.card_footer>
        </.card>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
