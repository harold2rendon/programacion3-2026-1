defmodule Inmobiliaria.SessionManager do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def login(username, user_data) do
    GenServer.call(__MODULE__, {:login, username, user_data})
  end

  def logout(username) do
    GenServer.cast(__MODULE__, {:logout, username})
  end

  def get_session(username) do
    GenServer.call(__MODULE__, {:get, username})
  end

  def active_users do
    GenServer.call(__MODULE__, :active_users)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:login, username, user_data}, _from, state) do
    {:reply, :ok, Map.put(state, username, user_data)}
  end

  @impl true
  def handle_call({:get, username}, _from, state) do
    case Map.get(state, username) do
      nil  -> {:reply, {:error, :not_logged_in}, state}
      user -> {:reply, {:ok, user}, state}
    end
  end

  @impl true
  def handle_call(:active_users, _from, state) do
    {:reply, Map.keys(state), state}
  end

  @impl true
  def handle_cast({:logout, username}, state) do
    {:noreply, Map.delete(state, username)}
  end
end
