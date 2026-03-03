defmodule Acceso do
  def validar do
  usuario = IO.gets("Ingrese su nombre de usuario: ")
    edad = IO.gets("Ingrese su edad: ")
    |> String.trim()
    |> String.to_integer()

  credenciales_validas = IO.gets("Tiene credenciales válidas? (s/n): ")
    |> String.trim()
    |> String.downcase()
    |> String.to_atom()

  intentos = IO.gets("Número de intentos fallidos: ")
    |> String.trim()
    |> String.to_integer()


  unless credenciales_validas do
    {:error, "Acceso denegado: Credenciales inválidas"}
  else
    if edad < 18 do
      {:error, "Acceso denegado: Debe ser mayor de edad"}
    else
      if intentos > 3 do
        {:error, "Acceso denegado: Demasiados intentos fallidos"}
      else
        {:ok, "Acceso concedido"}
      end
    end
  end
end
end

IO.inspect(Acceso.validar())
