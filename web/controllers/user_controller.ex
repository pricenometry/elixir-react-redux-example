defmodule ApiTest.UserController do
  use ApiTest.Web, :controller

  alias ApiTest.User
  alias ApiTest.Repo

  # Simple authentication provided by Guardian
  # This code will check every incoming HTTP request for a JWT in the 
  # 'Authorization' header
  plug Guardian.Plug.EnsureAuthenticated, on_failure: { ApiTest.SessionController, :unauthenticated_api }

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users) 
  end

  def current_user(conn, %{"jwt" => jwt}) do
    case Guardian.decode_and_verify(jwt) do
      { :ok, claims } -> 
        id = claims["sub"] |> String.replace("User:", "") |> String.to_integer
        user = Repo.get!(User, id)
        conn
        |> put_status(:ok)
        |> render("show.json", user: user)
      { :error, reason } ->
        conn
        |> put_status(:not_found)
        |> render(ApiTest.SessionView, "error.json", error: "Not Found")
    end
  end
end
