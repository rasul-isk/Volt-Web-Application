defmodule VoltWeb.Authentication do
  import Plug.Conn
  # use VolWeb, :plug

  def init(opts) do
    opts[:repo]
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user_role = conn.params["session"]["Role"] || get_session(conn, :role_type)
    if(!is_nil(user_role)) do
      path = String.to_existing_atom("Elixir.Volt.Accounts." <> user_role)
      user = user_id && repo.get(path, user_id)
      login(conn, user_id, user,user_role)
    else
      login(conn,user_id,nil, user_role)
    end
  end

  def login(conn, user_id, user, role) do
    assign(conn, :current_user, user)
    |> put_session(:user_id, user_id)
    |> put_session(:role_type, role)
  end


  def check_credentials(conn, email, crypted_password, [repo: repo]) do
    # user_id = get_session(conn, :user_id)
    user_role = conn.params["session"]["Role"]
    if(!is_nil(user_role)) do
      path = String.to_existing_atom("Elixir.Volt.Accounts." <> user_role)
      user = repo.get_by(path, email: email)
      if(!is_nil(user)) do
        if (Bcrypt.verify_pass(crypted_password,user.crypted_password)) do
          {:ok, login(conn, user.id, user,user_role) }
        else
          {:error, "Wrong email or password.", conn}
        end
      else
       {:error,"No such user found.",conn}
      end
    else
      {:error,"Role problem.",conn}
    end
  end
end
