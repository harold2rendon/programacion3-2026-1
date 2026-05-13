defmodule Inmobiliaria.Property do
  use GenServer
  require Logger

  # ── API pública ──────────────────────────────────────────────────────────────

  def start_link(property) do
    GenServer.start_link(__MODULE__, property, name: via(property.id))
  end

  def get(property_id) do
    GenServer.call(via(property_id), :get)
  end

  def buy(property_id, client_username) do
    GenServer.call(via(property_id), {:buy, client_username})
  end

  def rent(property_id, client_username) do
    GenServer.call(via(property_id), {:rent, client_username})
  end

  def update_status(property_id, new_status) do
    GenServer.cast(via(property_id), {:update_status, new_status})
  end

  # ── Callbacks GenServer ──────────────────────────────────────────────────────

  @impl true
  def init(property) do
    Logger.info("Propiedad iniciada como proceso: #{property.id}")
    {:ok, property}
  end

  @impl true
  def handle_call(:get, _from, property) do
    {:reply, property, property}
  end

  # Operación de compra — maneja concurrencia automáticamente (proceso único)
  @impl true
  def handle_call({:buy, client}, _from, property) do
    cond do
      property.modalidad != "venta" ->
        {:reply, {:error, "La propiedad no está en venta"}, property}

      property.estado != "disponible" ->
        {:reply, {:error, "La propiedad no está disponible (estado: #{property.estado})"}, property}

      true ->
        updated = %{property | estado: "vendida", comprador: client}
        {:reply, {:ok, updated}, updated}
    end
  end

  # Operación de arriendo
  @impl true
  def handle_call({:rent, client}, _from, property) do
    cond do
      property.modalidad != "arriendo" ->
        {:reply, {:error, "La propiedad no está en arriendo"}, property}

      property.estado != "disponible" ->
        {:reply, {:error, "La propiedad no está disponible (estado: #{property.estado})"}, property}

      true ->
        updated = %{property | estado: "arrendada", comprador: client}
        {:reply, {:ok, updated}, updated}
    end
  end

  @impl true
  def handle_cast({:update_status, new_status}, property) do
    {:noreply, %{property | estado: new_status}}
  end

  # ── Registro de nombre via Registry ─────────────────────────────────────────

 defp via(id) do
  {:via, Registry, {Inmobiliaria.PropertyRegistry, id}}
end
end
