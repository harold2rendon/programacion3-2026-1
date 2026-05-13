defmodule Inmobiliaria.Server do
  @moduledoc """
  Servidor CLI con soporte distribuido.
  """
@servidor :"servidor@127.0.0.1"

  alias Inmobiliaria.{UserManager, PropertyManager, MessageManager,
                       SessionManager, ResultsLogger}


  defp call_node(modulo, funcion, args) do
    if Node.self() == @servidor do
      apply(modulo, funcion, args)
    else
      :rpc.call(@servidor, modulo, funcion, args)
    end
  end

  # ── Punto de entrada ─────────────────────────────────────────────────────────

  def run do
    if Node.self() != @servidor do
      Node.connect(@servidor)
    end
    IO.puts(banner())
    loop_auth()
  end

  # ── Bucle sin sesión: login / registro ───────────────────────────────────────

  defp loop_auth do
    IO.puts("""

    ╔══════════════════════════════════════╗
    ║         ACCESO AL SISTEMA            ║
    ╠══════════════════════════════════════╣
    ║  1. Conectarse / Registrarse         ║
    ║  0. Salir                            ║
    ╚══════════════════════════════════════╝
    """)

    case leer("Opción: ") do
      "1" ->
        username = leer("Usuario: ")
        password = leer("Contraseña: ")
        rol      = leer("Rol (cliente/vendedor/arrendador) [cliente]: ")
        rol      = if rol == "", do: "cliente", else: rol

        case call_node(UserManager, :connect, [username, password, rol]) do
          {:ok, user} ->
            SessionManager.login(username, user)
            IO.puts("✔ Bienvenido, #{username}! Cuenta creada con rol: #{user.role}")
            loop_menu(user)

          {:error, reason} ->
            IO.puts("✖ Error: #{reason}")
            loop_auth()
        end

      "0" ->
        IO.puts("¡Hasta luego!")

      _ ->
        IO.puts("Opción inválida.")
        loop_auth()
    end
  end

  # ── Menú principal según rol ─────────────────────────────────────────────────

  defp loop_menu(user) do
    IO.puts(menu_para(user))
    opcion = leer("#{user.username} (#{user.role})> ")

    case user.role do
      "cliente"     -> handle_cliente(opcion, user)
      "vendedor"    -> handle_vendedor(opcion, user)
      "arrendador"  -> handle_arrendador(opcion, user)
      _             -> handle_cliente(opcion, user)
    end
  end

  # ── Menús por rol ─────────────────────────────────────────────────────────────

  defp menu_para(%{role: "cliente"}) do
    """

    ╔══════════════════════════════════════════╗
    ║            MENÚ - CLIENTE                ║
    ╠══════════════════════════════════════════╣
    ║  1. Ver propiedades disponibles          ║
    ║  2. Buscar propiedades                   ║
    ║  3. Ver detalle de propiedad             ║
    ║  4. Comprar propiedad                    ║
    ║  5. Arrendar propiedad                   ║
    ║  6. Enviar mensaje a propiedad           ║
    ║  7. Leer mensajes de propiedad           ║
    ║  8. Ver mi puntaje                       ║
    ║  9. Ver ranking global                   ║
    ║ 10. Ver historial de operaciones         ║
    ║ 11. Ver usuarios activos                 ║
    ║  0. Desconectarse                        ║
    ╚══════════════════════════════════════════╝
    """
  end

  defp menu_para(%{role: "vendedor"}) do
    """

    ╔══════════════════════════════════════════╗
    ║           MENÚ - VENDEDOR                ║
    ╠══════════════════════════════════════════╣
    ║  1. Publicar propiedad en venta          ║
    ║  2. Ver mis propiedades                  ║
    ║  3. Ver todas las propiedades            ║
    ║  4. Ver detalle de propiedad             ║
    ║  5. Leer mensajes de mi propiedad        ║
    ║  6. Mi bandeja de entrada                ║
    ║  7. Ver mi puntaje                       ║
    ║  8. Ranking vendedores                   ║
    ║  9. Ranking global                       ║
    ║ 10. Ver historial de operaciones         ║
    ║ 11. Ver usuarios activos                 ║
    ║  0. Desconectarse                        ║
    ╚══════════════════════════════════════════╝
    """
  end

  defp menu_para(%{role: "arrendador"}) do
    """

    ╔══════════════════════════════════════════╗
    ║          MENÚ - ARRENDADOR               ║
    ╠══════════════════════════════════════════╣
    ║  1. Publicar propiedad en arriendo       ║
    ║  2. Ver mis propiedades                  ║
    ║  3. Ver todas las propiedades            ║
    ║  4. Ver detalle de propiedad             ║
    ║  5. Leer mensajes de mi propiedad        ║
    ║  6. Mi bandeja de entrada                ║
    ║  7. Ver mi puntaje                       ║
    ║  8. Ranking arrendadores                 ║
    ║  9. Ranking global                       ║
    ║ 10. Ver historial de operaciones         ║
    ║ 11. Ver usuarios activos                 ║
    ║  0. Desconectarse                        ║
    ╚══════════════════════════════════════════╝
    """
  end

  # ── Acciones CLIENTE ─────────────────────────────────────────────────────────

  defp handle_cliente("1", user) do
    props = call_node(PropertyManager, :list_available, [])
    if props == [] do
      IO.puts("No hay propiedades disponibles.")
    else
      IO.puts("\n── Propiedades disponibles (#{length(props)}) ──")
      Enum.each(props, &IO.puts(format_property(&1)))
    end
    loop_menu(user)
  end

  defp handle_cliente("2", user) do
    IO.puts("\nDeja vacío para omitir un filtro.")
    tipo       = leer("Tipo (casa/apartamento/oficina/lote): ")
    modalidad  = leer("Modalidad (venta/arriendo): ")
    ubicacion  = leer("Ubicación: ")
    precio_min = leer("Precio mínimo: ")
    precio_max = leer("Precio máximo: ")

    filters =
      [
        (if tipo != "",       do: {:tipo, tipo}),
        (if modalidad != "",  do: {:modalidad, modalidad}),
        (if ubicacion != "",  do: {:ubicacion, ubicacion}),
        (if precio_min != "", do: {:precio_min, String.to_integer(precio_min)}),
        (if precio_max != "", do: {:precio_max, String.to_integer(precio_max)})
      ]
      |> Enum.reject(&is_nil/1)

    props = PropertyManager.search(filters)
    if props == [] do
      IO.puts("No se encontraron propiedades con esos filtros.")
    else
      IO.puts("\n── Resultados (#{length(props)}) ──")
      Enum.each(props, &IO.puts(format_property(&1)))
    end
    loop_menu(user)
  end

  defp handle_cliente("3", user) do
    id = leer("ID de propiedad: ")
    case PropertyManager.get(String.trim(id)) do
      {:ok, prop} -> IO.puts(format_property_detail(prop))
      {:error, r} -> IO.puts("Error: #{r}")
    end
    loop_menu(user)
  end

  defp handle_cliente("4", user) do
    id = String.trim(leer("ID de propiedad a comprar: "))
   case :rpc.call(@servidor, Inmobiliaria.Property, :buy, [id, user.username]) do
      {:ok, prop} ->
        call_node(PropertyManager, :update, [id, %{estado: "vendida", comprador: user.username}])
        call_node(UserManager, :add_points, [user.username, 10])
        call_node(ResultsLogger, :log_operation, [user.username, prop.propietario, prop, "compra"])
        IO.puts("✔ ¡Compra realizada con éxito!")
      {:error, r} ->
        IO.puts("✖ Error: #{r}")
    end
    loop_menu(user)
  end

  defp handle_cliente("5", user) do
    id = String.trim(leer("ID de propiedad a arrendar: "))
    try do
    case :rpc.call(@servidor, Inmobiliaria.Property, :rent, [id, user.username]) do
      {:ok, _prop} ->
        call_node(PropertyManager, :update, [id, %{estado: "arrendada", comprador: user.username}])
        call_node(UserManager, :add_points, [user.username, 5])
        IO.puts("✔ ¡Arriendo realizado con éxito!")
      {:error, reason} ->
        IO.puts("✖ No se pudo completar: #{reason}")
        {:badrpc, _} ->
        IO.puts("✖ Error de comunicación con el servidor.")
    end
    catch
      :exit, _ -> IO.puts("Error: La propiedad no está disponible #{id} o el servidor no responde.")
    end
    loop_menu(user)
end

  defp handle_cliente("6", user) do
    id      = String.trim(leer("ID de propiedad: "))
    mensaje = leer("Mensaje: ")
    case call_node(MessageManager, :send_message, [id, user.username, mensaje]) do
      :ok -> IO.puts("✔ Mensaje enviado.")
      _   -> IO.puts("✖ Error al enviar mensaje.")
    end
    loop_menu(user)
  end

  defp handle_cliente("7", user) do
    id   = String.trim(leer("ID de propiedad: "))
    msgs = MessageManager.get_messages(id)
    if msgs == [] do
      IO.puts("No hay mensajes para esa propiedad.")
    else
      IO.puts("\n── Mensajes (#{id}) ──")
      Enum.each(msgs, fn m -> IO.puts("  [#{m.timestamp}] #{m.from}: #{m.message}") end)
    end
    loop_menu(user)
  end

  defp handle_cliente("8", user) do
    case call_node(UserManager, :get_user, [user.username]) do
      {:ok, u} -> IO.puts("Tu puntaje: #{u.points} puntos")
      _        -> IO.puts("No se pudo obtener el puntaje.")
    end
    loop_menu(user)
  end

  defp handle_cliente("9", user) do
    ranking = call_node(UserManager, :ranking, [])
    IO.puts(format_ranking("Ranking Global", ranking))
    loop_menu(user)
  end

  defp handle_cliente("10", user) do
    content = ResultsLogger.read_all()
    if content == "", do: IO.puts("No hay historial."), else: IO.puts("\n── Historial ──\n#{content}")
    loop_menu(user)
  end

  defp handle_cliente("11", user) do
    IO.puts("Usuarios activos: #{Enum.join(SessionManager.active_users(), ", ")}")
    loop_menu(user)
  end

  defp handle_cliente("0", user) do
    UserManager.disconnect(user.username)
    SessionManager.logout(user.username)
    IO.puts("Hasta luego, #{user.username}!")
    loop_auth()
  end

  defp handle_cliente(_, user) do
    IO.puts("Opción inválida.")
    loop_menu(user)
  end

  # ── Acciones VENDEDOR ─────────────────────────────────────────────────────────

  defp handle_vendedor("1", user) do
    IO.puts("\nIngresa los datos de la propiedad:")
    tipo        = leer("Tipo (casa/apartamento/oficina/lote): ")
    ubicacion   = leer("Ubicación: ")
    precio      = leer("Precio: ")
    habitaciones = leer("Habitaciones: ")
    area        = leer("Área (m²): ")

    attrs = %{
      tipo: tipo,
      modalidad: "venta",
      ubicacion: ubicacion,
      precio: precio,
      habitaciones: habitaciones,
      area: area,
      propietario: user.username
    }

    case PropertyManager.publish(attrs) do
      {:ok, prop} -> IO.puts("✔ Propiedad publicada con ID: #{prop.id}\n#{format_property(prop)}")
      {:error, r} -> IO.puts("✖ Error: #{r}")
    end
    loop_menu(user)
  end

  defp handle_vendedor("2", user) do
    props = PropertyManager.list_by_owner(user.username)
    if props == [] do
      IO.puts("No tienes propiedades publicadas.")
    else
      IO.puts("\n── Tus propiedades ──")
      Enum.each(props, &IO.puts(format_property(&1)))
    end
    loop_menu(user)
  end

  defp handle_vendedor("3", user) do
    props = PropertyManager.list_available()
    if props == [] do
      IO.puts("No hay propiedades disponibles.")
    else
      IO.puts("\n── Propiedades disponibles ──")
      Enum.each(props, &IO.puts(format_property(&1)))
    end
    loop_menu(user)
  end

  defp handle_vendedor("4", user) do
    id = leer("ID de propiedad: ")
    case PropertyManager.get(String.trim(id)) do
      {:ok, prop} -> IO.puts(format_property_detail(prop))
      {:error, r} -> IO.puts("Error: #{r}")
    end
    loop_menu(user)
  end

  defp handle_vendedor("5", user) do
    id   = String.trim(leer("ID de propiedad: "))
    msgs = MessageManager.get_messages(id)
    if msgs == [] do
      IO.puts("No hay mensajes para esa propiedad.")
    else
      IO.puts("\n── Mensajes (#{id}) ──")
      Enum.each(msgs, fn m -> IO.puts("  [#{m.timestamp}] #{m.from}: #{m.message}") end)
    end
    loop_menu(user)
  end

  defp handle_vendedor("6", user) do
    msgs = call_node(MessageManager, :get_inbox, [user.username])
    if msgs == [] do
      IO.puts("No tienes mensajes en tu bandeja.")
    else
      IO.puts("\n── Bandeja de entrada ──")
      Enum.each(msgs, fn m -> IO.puts("  [#{m.property_id}] #{m.from}: #{m.message}") end)
    end
    loop_menu(user)
  end

  defp handle_vendedor("7", user) do
    case UserManager.get_user(user.username) do
      {:ok, u} -> IO.puts("Tu puntaje: #{u.points} puntos")
      _        -> IO.puts("No se pudo obtener el puntaje.")
    end
    loop_menu(user)
  end

  defp handle_vendedor("8", user) do
    IO.puts(format_ranking("Ranking Vendedores", UserManager.ranking_by_role("vendedor")))
    loop_menu(user)
  end

  defp handle_vendedor("9", user) do
    IO.puts(format_ranking("Ranking Global", UserManager.ranking()))
    loop_menu(user)
  end

  defp handle_vendedor("10", user) do
    content = ResultsLogger.read_all()
    if content == "", do: IO.puts("No hay historial."), else: IO.puts("\n── Historial ──\n#{content}")
    loop_menu(user)
  end

  defp handle_vendedor("11", user) do
    IO.puts("Usuarios activos: #{Enum.join(SessionManager.active_users(), ", ")}")
    loop_menu(user)
  end

  defp handle_vendedor("0", user) do
    UserManager.disconnect(user.username)
    SessionManager.logout(user.username)
    IO.puts("Hasta luego, #{user.username}!")
    loop_auth()
  end

  defp handle_vendedor(_, user) do
    IO.puts("Opción inválida.")
    loop_menu(user)
  end

  # ── Acciones ARRENDADOR ───────────────────────────────────────────────────────

  defp handle_arrendador("1", user) do
    IO.puts("\nIngresa los datos de la propiedad:")
    tipo         = leer("Tipo (casa/apartamento/oficina/lote): ")
    ubicacion    = leer("Ubicación: ")
    precio       = leer("Precio mensual: ")
    habitaciones = leer("Habitaciones: ")
    area         = leer("Área (m²): ")

    attrs = %{
      tipo: tipo,
      modalidad: "arriendo",
      ubicacion: ubicacion,
      precio: precio,
      habitaciones: habitaciones,
      area: area,
      propietario: user.username
    }

    case PropertyManager.publish(attrs) do
      {:ok, prop} -> IO.puts("✔ Propiedad publicada con ID: #{prop.id}\n#{format_property(prop)}")
      {:error, r} -> IO.puts("✖ Error: #{r}")
    end
    loop_menu(user)
  end

  # Opciones 2–11 y 0 son idénticas al vendedor
  defp handle_arrendador("2", user),  do: handle_vendedor("2", user)
  defp handle_arrendador("3", user),  do: handle_vendedor("3", user)
  defp handle_arrendador("4", user),  do: handle_vendedor("4", user)
  defp handle_arrendador("5", user),  do: handle_vendedor("5", user)
  defp handle_arrendador("6", user),  do: handle_vendedor("6", user)
  defp handle_arrendador("7", user),  do: handle_vendedor("7", user)
  defp handle_arrendador("8", user) do
    IO.puts(format_ranking("Ranking Arrendadores", UserManager.ranking_by_role("arrendador")))
    loop_menu(user)
  end
  defp handle_arrendador("9", user),  do: handle_vendedor("9", user)
  defp handle_arrendador("10", user), do: handle_vendedor("10", user)
  defp handle_arrendador("11", user), do: handle_vendedor("11", user)
  defp handle_arrendador("0", user),  do: handle_vendedor("0", user)
  defp handle_arrendador(_, user) do
    IO.puts("Opción inválida.")
    loop_menu(user)
  end

  # ── Helpers ──────────────────────────────────────────────────────────────────

  defp leer(prompt) do
    IO.gets(prompt) |> String.trim()
  end

  defp format_property(p) do
    """
    ┌─ #{p.id} ─────────────────────────────────
    │ Tipo: #{p.tipo} | Modalidad: #{p.modalidad} | Estado: #{p.estado}
    │ Ubicación: #{p.ubicacion} | Precio: $#{p.precio}
    │ Habitaciones: #{p.habitaciones} | Área: #{p.area}m² | Propietario: #{p.propietario}
    └───────────────────────────────────────────
    """
  end

  defp format_property_detail(p) do
    comprador = if p.comprador, do: "\n║ Comprador: #{p.comprador}", else: ""
    """
    ╔═ #{p.id} ════════════════════════════════
    ║ Tipo        : #{p.tipo}
    ║ Modalidad   : #{p.modalidad}
    ║ Estado      : #{p.estado}
    ║ Ubicación   : #{p.ubicacion}
    ║ Precio      : $#{p.precio}
    ║ Habitaciones: #{p.habitaciones}
    ║ Área        : #{p.area}m²
    ║ Propietario : #{p.propietario}#{comprador}
    ╚════════════════════════════════════════════
    """
  end

  defp format_ranking(title, users) do
    if users == [] do
      "No hay usuarios en este ranking."
    else
      rows =
        users
        |> Enum.with_index(1)
        |> Enum.map_join("\n", fn {u, i} ->
          "  #{i}. #{u.username} (#{u.role}) — #{u.points} pts"
        end)
      "\n── #{title} ──\n#{rows}"
    end
  end

  defp banner do
    """
    ╔══════════════════════════════════════════════════╗
    ║     SISTEMA DE GESTIÓN INMOBILIARIA - Elixir     ║
    ║         Universidad del Quindío — 2026           ║
    ╚══════════════════════════════════════════════════╝
    """
  end
end
