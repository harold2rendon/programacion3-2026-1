defmodule Inmobiliaria.UserManager do
  use GenServer
  require Logger

  @users_file "data/users.dat"

  # ── API pública ──────────────────────────────────────────────────────────────

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @doc "Conecta o registra un usuario. Devuelve {:ok, user} | {:error, reason}"
  def connect(username, password, role \\ "cliente") do
    GenServer.call(__MODULE__, {:connect, username, password, role})
  end

  def disconnect(username) do
    GenServer.call(__MODULE__, {:disconnect, username})
  end

  def get_user(username) do
    GenServer.call(__MODULE__, {:get_user, username})
  end

  def add_points(username, points) do
    GenServer.cast(__MODULE__, {:add_points, username, points})
  end

  def ranking do
    GenServer.call(__MODULE__, :ranking)
  end

  def ranking_by_role(role) do
    GenServer.call(__MODULE__, {:ranking_by_role, role})
  end

  # ── Callbacks GenServer ──────────────────────────────────────────────────────

  @impl true
  def init(_) do
    users = load_users()
    {:ok, %{users: users}}
  end

  @impl true
  def handle_call({:connect, username, password, role}, _from, state) do
    case Map.get(state.users, username) do
      nil ->
        # Registro automático
        new_user = %{
          username: username,
          password: password,
          role: role,
          points: 0
        }
        new_users = Map.put(state.users, username, new_user)
        save_users(new_users)
        Logger.info("Nuevo usuario registrado: #{username} (#{role})")
        {:reply, {:ok, new_user}, %{state | users: new_users}}

      user ->
        if user.password == password do
          {:reply, {:ok, user}, state}
        else
          {:reply, {:error, "Contraseña incorrecta"}, state}
        end
    end
  end

  @impl true
  def handle_call({:disconnect, username}, _from, state) do
    Logger.info("Usuario desconectado: #{username}")
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get_user, username}, _from, state) do
    case Map.get(state.users, username) do
      nil -> {:reply, {:error, "Usuario no encontrado"}, state}
      user -> {:reply, {:ok, user}, state}
    end
  end

  @impl true
  def handle_call(:ranking, _from, state) do
    ranking =
      state.users
      |> Map.values()
      |> Enum.sort_by(& &1.points, :desc)
    {:reply, ranking, state}
  end

  @impl true
  def handle_call({:ranking_by_role, role}, _from, state) do
    ranking =
      state.users
      |> Map.values()
      |> Enum.filter(&(&1.role == role))
      |> Enum.sort_by(& &1.points, :desc)
    {:reply, ranking, state}
  end

  @impl true
  def handle_cast({:add_points, username, points}, state) do
    new_users =
      Map.update(state.users, username, %{}, fn user ->
        %{user | points: user.points + points}
      end)
    save_users(new_users)
    {:noreply, %{state | users: new_users}}
  end

  # ── Persistencia ─────────────────────────────────────────────────────────────

  defp load_users do
    case File.read(@users_file) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.reduce(%{}, fn line, acc ->
          case String.split(line, ";") do
            [username, role, password, points] ->
              user = %{
                username: String.trim(username),
                role: String.trim(role),
                password: String.trim(password),
                points: String.to_integer(String.trim(points))
              }
              Map.put(acc, user.username, user)
            _ -> acc
          end
        end)

      {:error, _} ->
        File.mkdir_p!(Path.dirname(@users_file))
        File.write!(@users_file, "")
        %{}
    end
  end

  defp save_users(users) do
    content =
      users
      |> Map.values()
      |> Enum.map(fn u ->
        "#{u.username};#{u.role};#{u.password};#{u.points}"
      end)
      |> Enum.join("\n")

    File.write!(@users_file, content)
  end
end
