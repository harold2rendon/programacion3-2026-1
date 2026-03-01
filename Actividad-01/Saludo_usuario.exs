defmodule SaludoUsuario do
  
# Saludar a un usuario dependiendo de la hora del día.
  def saludar do
    IO.puts("ingrese su nombre: ")
    nombre = IO.gets("")
    |> String.trim()

    {{_, _, _}, {hora, _, _}} = :calendar.local_time()

    # Determinar el saludo basado en la hora
    mensaje =
      cond do
        hora >= 0 and hora < 12 -> "Buenos días #{nombre}"
        hora >= 12 and hora < 18 -> "Buenas tardes #{nombre}"
        true -> "Buenas noches #{nombre}"
      end
    IO.puts(mensaje)
  end
end

SaludoUsuario.saludar()
