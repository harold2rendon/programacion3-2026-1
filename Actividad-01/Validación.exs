defmodule Validacion do

# Validar un nombre de usuario.
  def validar do
    nombre =
      IO.gets("Ingrese su nombre de usuario: ")
      |> String.trim()

    no_valido =
      []
      |> verificar_longitud(nombre)
      |> verificar_minuscula(nombre)
      |> verificar_espacios(nombre)
      |> verificar_caracteres_especiales(nombre)
      |> verificar_letra(nombre)

    case no_valido do
      [] ->
        {:ok, "Nombre válido"}

      _ ->
        {:error, no_valido}
    end
  end

# Funciones para la validación

  # Verificar que el nombre tenga entre 5 y 12 caracteres
  def verificar_longitud(lista, nombre) do
    if String.length(nombre) >= 5 and String.length(nombre) <= 12 do
      lista
    else
      lista ++ ["El nombre debe tener entre 5 y 12 caracteres"]
    end
  end

  # Verificar que el nombre esté en minúsculas
  def verificar_minuscula(lista, nombre) do
    if nombre == String.downcase(nombre) do
      lista
    else
      lista ++ ["El nombre debe estar en minúsculas"]
    end
  end

  # Verificar que el nombre no contenga espacios
  def verificar_espacios(lista, nombre) do
    if String.contains?(nombre, " ") do
      lista ++ ["El nombre no debe contener espacios"]
    else
      lista
    end
  end

  # Verificar que el nombre no contenga caracteres especiales
  def verificar_caracteres_especiales(lista, nombre) do
    if String.match?(nombre, ~r/^[a-z0-9]+$/) do
      lista
    else
      lista ++ ["El nombre no debe contener caracteres especiales"]
    end
  end

  # Verificar que el nombre contenga al menos una letra
  def verificar_letra(lista, nombre) do
    if String.match?(nombre, ~r/[a-z]/) do
      lista
    else
      lista ++ ["El nombre debe contener letra"]
    end
  end

end


IO.inspect(Validacion.validar())
