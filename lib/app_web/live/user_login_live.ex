defmodule AppWeb.UserLoginLive do
  use AppWeb, :live_view

  import AppWeb.Component.Button
  import AppWeb.Component.Form
  import AppWeb.Component.Card
  import AppWeb.Component.Label

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.card>
          <.card_header>
            <label class="text-2xl font-bold">Welcome back</label>
          </.card_header>

          <.card_content class="space-y-5">
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
              <div class="flex items-center h-5"><.input id="remember" field={@form[:remember_me]} type="checkbox" /></div>
              <div class="ml-3 text-sm"><.label for="remember">Remember me</.label></div>
            </div>
            <.link href={~p"/users/reset_password"} class="text-sm font-medium hover:underline ">
              Forgot your password?
            </.link>
          </.card_content>

          <.card_footer class="flex-col gap-4">
            <.button phx-disable-with="Logging in..." class="w-full">
              Sign in <span aria-hidden="true">→</span>
            </.button>
            <p class="text-sm">
              Don't have an account?
              <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
                Sign up
              </.link>
            </p>
          </.card_footer>
        </.card>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
