defmodule Volt.Email do
  use Bamboo.Phoenix, view: VoltWeb.EmailView

  def password_reset(user) do

    new_email()
    |> from("no-reply@elixircasts.io")
    |> to(user.email)
    |> subject("Password Reset")
    |> put_html_layout({VoltWeb.LayoutView, "email.html"})
    |> assign(:user, user)
    |> render("password_reset.html")
  end
end
