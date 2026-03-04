defmodule Cupon do

# Validar un código de cupón, el cual debe tener al menos 10 caracteres, contener al menos una mayúscula, al menos un número y no debe contener espacios.
  def main do
    codigo_cupon =
      Util.leer_cadena("Ingrese el codigo del cupon: ")

    validaciones =
      []
      |> validar_longitud(codigo_cupon)
      |> validar_mayuscula(codigo_cupon)
      |> validar_digitos(codigo_cupon)
      |> validar_espacios(codigo_cupon)

    resultado(validaciones)
    |> mostrar()

  end

# Función para mostrar el resultado de la validación.
  def resultado([]),
    do: {:ok, "Cupón válido"}

  def resultado(lista),
    do: {:error, Enum.join(lista, " y ")}


  def mostrar({:ok, mensaje}),
    do: IO.puts(mensaje)

  def mostrar({:error, mensaje}),
    do: IO.puts(mensaje)

# Funciones de validación para cada criterio del código de cupón.
  def validar_longitud(lista, codigo) do
    if String.length(codigo) >= 10 do
      lista
    else
      lista ++ ["Debe tener al menos 10 caracteres"]
    end
  end


  def validar_mayuscula(lista, codigo) do
    if codigo != String.downcase(codigo) do
      lista
    else
      lista ++ ["Debe contener al menos una mayúscula"]
    end
  end


  def validar_digitos(lista, codigo) do
    sin_numeros = String.replace(codigo, ~r/[0-9]/, "")

    if sin_numeros != codigo do
      lista
    else
      lista ++ ["Debe contener al menos un número"]
    end
  end


  def validar_espacios(lista, codigo) do
    if String.contains?(codigo, " ") do
      lista ++ ["No debe contener espacios"]
    else
      lista
    end
  end
end

Cupon.main()
