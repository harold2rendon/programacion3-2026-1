defmodule Inmobiliaria.PropertyManager do
  use GenServer
  require Logger

  @properties_file "data/properties.dat"

  # ── API pública ──────────────────────────────────────────────────────────────

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def publish(property_attrs) do
    GenServer.call(__MODULE__, {:publish, property_attrs})
  end

  def list_all do
    GenServer.call(__MODULE__, :list_all)
  end

  def list_available do
    GenServer.call(__MODULE__, :list_available)
  end

  def search(filters) do
    GenServer.call(__MODULE__, {:search, filters})
  end

  def get(property_id) do
    GenServer.call(__MODULE__, {:get, property_id})
  end

  def update(property_id, attrs) do
    GenServer.cast(__MODULE__, {:update, property_id, attrs})
  end

  def list_by_owner(owner) do
    GenServer.call(__MODULE__, {:list_by_owner, owner})
  end

  # ── Callbacks ────────────────────────────────────────────────────────────────

  @impl true
  def init(_) do
    properties = load_properties()
    # Levantar un proceso por cada propiedad existente
    Enum.each(properties, fn {_id, prop} ->
      Inmobiliaria.PropertySupervisor.start_property(prop)
    end)
    {:ok, %{properties: properties, counter: map_size(properties)}}
  end

  @impl true
  def handle_call({:publish, attrs}, _from, state) do
    new_counter = state.counter + 1
    id = "prop#{String.pad_leading(to_string(new_counter), 3, "0")}"

    property = %{
      id: id,
      tipo: attrs[:tipo] || "casa",
      modalidad: attrs[:modalidad] || "venta",
      ubicacion: attrs[:ubicacion] || "Sin ubicación",
      precio: attrs[:precio] || 0,
      habitaciones: attrs[:habitaciones] || 0,
      area: attrs[:area] || 0,
      estado: "disponible",
      propietario: attrs[:propietario],
      comprador: nil
    }

    new_properties = Map.put(state.properties, id, property)
    save_properties(new_properties)

    # Iniciar proceso independiente para esta propiedad
    Inmobiliaria.PropertySupervisor.start_property(property)

    Logger.info("Propiedad publicada: #{id} por #{property.propietario}")
    {:reply, {:ok, property}, %{state | properties: new_properties, counter: new_counter}}
  end

  @impl true
  def handle_call(:list_all, _from, state) do
    list = Map.values(state.properties)
    {:reply, list, state}
  end

  @impl true
  def handle_call(:list_available, _from, state) do
    list =
      state.properties
      |> Map.values()
      |> Enum.filter(&(&1.estado == "disponible"))
    {:reply, list, state}
  end

  @impl true
  def handle_call({:search, filters}, _from, state) do
    results =
      state.properties
      |> Map.values()
      |> Enum.filter(fn p ->
        Enum.all?(filters, fn
          {:tipo, v}      -> p.tipo == v
          {:modalidad, v} -> p.modalidad == v
          {:ubicacion, v} -> String.contains?(String.downcase(p.ubicacion), String.downcase(v))
          {:precio_min, v} -> p.precio >= v
          {:precio_max, v} -> p.precio <= v
          {:estado, v}    -> p.estado == v
          _               -> true
        end)
      end)
    {:reply, results, state}
  end

  @impl true
  def handle_call({:get, id}, _from, state) do
    case Map.get(state.properties, id) do
      nil -> {:reply, {:error, "Propiedad no encontrada"}, state}
      p   -> {:reply, {:ok, p}, state}
    end
  end

  @impl true
  def handle_call({:list_by_owner, owner}, _from, state) do
    list =
      state.properties
      |> Map.values()
      |> Enum.filter(&(&1.propietario == owner))
    {:reply, list, state}
  end

  @impl true
  def handle_cast({:update, id, attrs}, state) do
    new_properties =
      Map.update(state.properties, id, %{}, fn prop ->
        Map.merge(prop, attrs)
      end)
    save_properties(new_properties)
    {:noreply, %{state | properties: new_properties}}
  end

  # ── Persistencia ─────────────────────────────────────────────────────────────

  defp load_properties do
    case File.read(@properties_file) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.reduce(%{}, fn line, acc ->
          case String.split(line, ";") do
            # Validamos que existan los 10 campos y que NO estén vacíos
            [id, t, m, u, precio, hab, area, est, prop_id, comp] when precio != "" and hab != "" and area != "" ->
              try do
                prop = %{
                  id: String.trim(id),
                  tipo: String.trim(t),
                  modalidad: String.trim(m),
                  ubicacion: String.trim(u),
                  precio: String.to_integer(String.trim(precio)),
                  habitaciones: String.to_integer(String.trim(hab)),
                  area: String.to_integer(String.trim(area)),
                  estado: String.trim(est),
                  propietario: String.trim(prop_id),
                  comprador: if(String.trim(comp) == "nil", do: nil, else: String.trim(comp))
                }
                Map.put(acc, prop.id, prop)
              rescue
                _ -> acc # Si falla la conversión a entero, ignora esta línea y sigue
              end

            _ -> acc # Ignora líneas vacías o con formato incorrecto
          end
        end)

      {:error, _} ->
        File.mkdir_p!(Path.dirname(@properties_file))
        File.write!(@properties_file, "")
        %{}
    end
  end

  defp save_properties(properties) do
    content =
      properties
      |> Map.values()
      |> Enum.map(fn p ->
        "#{p.id};#{p.tipo};#{p.modalidad};#{p.ubicacion};#{p.precio};" <>
        "#{p.habitaciones};#{p.area};#{p.estado};#{p.propietario};#{p.comprador}"
      end)
      |> Enum.join("\n")

    File.write!(@properties_file, content)
  end
end
