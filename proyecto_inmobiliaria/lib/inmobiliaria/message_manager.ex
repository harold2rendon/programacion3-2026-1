defmodule Inmobiliaria.MessageManager do
  use GenServer

  @messages_file "data/messages.log"

  # ── API pública ──────────────────────────────────────────────────────────────

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def send_message(property_id, from_user, message) do
    GenServer.call(__MODULE__, {:send, property_id, from_user, message})
  end

  def get_messages(property_id) do
    GenServer.call(__MODULE__, {:get, property_id})
  end

  def get_inbox(owner_username) do
    GenServer.call(__MODULE__, {:inbox, owner_username})
  end

  # ── Callbacks ────────────────────────────────────────────────────────────────

  @impl true
  def init(_) do
    messages = load_messages()
    {:ok, %{messages: messages}}
  end

  @impl true
  def handle_call({:send, property_id, from_user, message}, _from, state) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    entry = %{
      property_id: property_id,
      from: from_user,
      message: message,
      timestamp: timestamp
    }

    new_messages = [entry | state.messages]
    save_messages(new_messages)
    {:reply, :ok, %{state | messages: new_messages}}
  end

  @impl true
  def handle_call({:get, property_id}, _from, state) do
    msgs =
      state.messages
      |> Enum.filter(&(&1.property_id == property_id))
      |> Enum.reverse()
    {:reply, msgs, state}
  end

  @impl true
  def handle_call({:inbox, owner}, _from, state) do
    # Buscar mensajes de propiedades que pertenecen al owner
    msgs =
      state.messages
      |> Enum.filter(fn m ->
        case Inmobiliaria.PropertyManager.get(m.property_id) do
          {:ok, prop} -> prop.propietario == owner
          _ -> false
        end
      end)
      |> Enum.reverse()
    {:reply, msgs, state}
  end

  # ── Persistencia ─────────────────────────────────────────────────────────────

  defp load_messages do
    case File.read(@messages_file) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          case String.split(line, "|") do
            [ts, property_id, from, message] ->
              %{timestamp: ts, property_id: property_id, from: from, message: message}
            _ -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      {:error, _} ->
        File.mkdir_p!(Path.dirname(@messages_file))
        File.write!(@messages_file, "")
        []
    end
  end

  defp save_messages(messages) do
    content =
      messages
      |> Enum.reverse()
      |> Enum.map(fn m ->
        "#{m.timestamp}|#{m.property_id}|#{m.from}|#{m.message}"
      end)
      |> Enum.join("\n")

    File.write!(@messages_file, content)
  end
end
