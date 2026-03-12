# Taller de CRUD con Listas en Elixir
defmodule Taller do

  def main do
    agenda([])
  end

# Función para mostrar el menú y manejar las opciones del usuario
  def agenda(citas) do
    IO.puts("\n SISTEMA DE CITAS TALLER MECANICO ")
    IO.puts("1. Agendar cita")
    IO.puts("2. Ver citas agendadas")
    IO.puts("3. Buscar cita")
    IO.puts("4. Actualizar cita")
    IO.puts("5. Eliminar cita")
    IO.puts("6. Salir")

    opcion = IO.gets("Seleccione una opción: ")
    |> String.trim()
    |> String.to_integer()

    case opcion do
      1 ->
        {:ok, nuevas_citas} = agendar_cita(citas)
        agenda(nuevas_citas)

      2 ->
        ver_citas(citas)
        agenda(citas)

      3 ->
        buscar_cita(citas)
        agenda(citas)

      4 ->
        {:ok, nuevas_citas} = actualizar_cita(citas)
        agenda(nuevas_citas)

      5 ->
        {:ok, nuevas_citas} = eliminar_cita(citas)
        agenda(nuevas_citas)

      6 ->
        IO.puts("Saliendo del sistema. ¡Hasta luego!")

      _ ->
        IO.puts("Opción no válida. Intente nuevamente.")
        agenda(citas)
      end
  end

  # Función para agendar una nueva cita
  def agendar_cita(citas) do
    id_ = Util.leer_cadena("Ingrese el ID de la cita: ")

    no_letras = Regex.match?(~r/^[0-9]+$/, id_)

    cond do
      not no_letras ->
        IO.puts("Error: El ID debe ser un número entero.")
        {:ok, citas}

      Enum.any?(citas, fn cita -> cita.id == String.to_integer(id_) end) ->
        IO.puts("Error: El ID ya existe.")
        {:ok, citas}

      true ->
      id = String.to_integer(id_)
      cliente = Util.leer_cadena("Ingrese el nombre del cliente: ")
      vehiculo = Util.leer_cadena("Ingrese el vehículo: ")
      fecha = Util.leer_cadena("Ingrese la fecha de la cita (YYYY-MM-DD): ")
      hora = Util.leer_cadena("Ingrese la hora de la cita (HH:MM): ")
      servicio = Util.leer_cadena("Ingrese el servicio requerido: ")

      nueva_cita = %{id: id, cliente: cliente, vehiculo: vehiculo, fecha: fecha, hora: hora, servicio: servicio}
      {:ok,  citas ++ [nueva_cita]}
    end
  end

  # Función para mostrar todas las citas agendadas
  def ver_citas(citas) do
    if citas == [] do
      IO.puts("No hay citas agendadas.")
    else
      Enum.each(citas, fn cita -> IO.puts("
        ID: #{cita.id},
        Cliente: #{cita.cliente},
        Vehículo: #{cita.vehiculo},
        Fecha: #{cita.fecha},
        Hora: #{cita.hora},
        Servicio: #{cita.servicio}")
      end)
    end
  end

  # Función para buscar una cita por ID
  def buscar_cita(citas) do
    id = Util.leer_entero("Ingrese el ID de la cita a buscar: ")
    cita = Enum.find(citas, fn cita -> cita.id == id end)

    case cita do
      nil -> IO.puts("Cita no encontrada.")
      cita -> IO.puts("ID: #{cita.id}, Cliente: #{cita.cliente}, Vehículo: #{cita.vehiculo}, Fecha: #{cita.fecha}, Hora: #{cita.hora}, Servicio: #{cita.servicio}")
    end
  end

  # Función para actualizar una cita existente
  def actualizar_cita (citas) do
    id = Util.leer_entero("Ingrese el ID de la cita a actualizar: ")
    nuevo_servicio = Util.leer_cadena("Ingrese el nuevo servicio: ")
    nueva_fecha = Util.leer_cadena("Ingrese la nueva fecha (YYYY-MM-DD): ")
    nueva_hora = Util.leer_cadena("Ingrese la nueva hora (HH:MM): ")

    nuevas_citas = Enum.map(citas, fn cita ->
      if cita.id == id do
        %{cita | servicio: nuevo_servicio, fecha: nueva_fecha, hora: nueva_hora}
      else
        cita
      end
    end)

    {:ok, nuevas_citas}
  end

  # Función para eliminar una cita por ID
  def eliminar_cita(citas) do
    id = Util.leer_entero("Ingrese el ID de la cita a eliminar: ")
    nuevas_citas = Enum.reject(citas, fn cita -> cita.id == id end)

    {:ok, nuevas_citas}
  end
end

Taller.main()
