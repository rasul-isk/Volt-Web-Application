defmodule VoltWeb.PasswordResetController do
  use VoltWeb, :controller
  alias Volt.Accounts
  alias Volt.Accounts.{Customer, Courier, Restaurant}

  alias Volt.Repo
  alias Volt.{Email, Mailer, Accounts}

  def new(conn,_params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    case Accounts.get_user_from_email(email) do
    nil -> conn
            |> put_flash(:info, "No email exists")
            |> redirect(to: Routes.password_reset_path(conn, :new))
    user ->
            user
            |> Accounts.set_token_on_user()
            |> Volt.Email.password_reset()
            |> Mailer.deliver_now()

            conn
            |> put_flash(:info, " Email sent with password reset instructions")
            |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end

  def edit(conn, %{"id" => token}) do
    customer = Repo.get_by(Customer, password_reset_token: token)
    courier = Repo.get_by(Courier, password_reset_token: token)
    restaurant = Repo.get_by(Restaurant, password_reset_token: token)
    user = customer || courier || restaurant
    role = String.to_existing_atom("Elixir.Volt.Accounts." <> user.role)
    # throw role
    if user do
      changeset = role.changeset(user, %{})
      render(conn, "edit.html", current_user: user, changeset: changeset)
    else
      render(conn, "invalid_token.html")
    end
  end

  def update(conn, params) do
    role_string = params["courier"] !=nil && "courier"
    role_string = (params["customer"] !=nil && "customer") || role_string
    role_string = (params["restaurant"] !=nil && "restaurant") || role_string

    user = Accounts.get_user(role_string, params["id"])
    role = String.to_existing_atom("Elixir.Volt.Accounts." <> user.role)

    password = params[role_string]["crypted_password"]
    password = Bcrypt.hash_pwd_salt(password)

    edited_attrs = %{"crypted_password" => password, "password_reset_token" => nil, "password_reset_sent_at" => nil}

    with true <- Accounts.valid_token?(user.password_reset_sent_at),
        {:ok, _updated_user} <- Accounts.update_user(user, edited_attrs) do
          conn
          |> put_flash(:info, "Your password has been reset. Sign in below with your new password.")
          |> redirect(to: Routes.session_path(conn, :new))
        else
          {:error, changeset} ->
            conn
            |> put_flash(:error, "Problem changing your password")
            |> render("edit.html", current_user: user, changeset: changeset)
      false ->
            conn
            |> put_flash(:error, "Reset token expired - request new one")
            |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end
end
