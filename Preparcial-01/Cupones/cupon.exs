defmodule Cupon do

  def main do
    codigo_cupon =
      Util.leer_cadena("Ingrese el codigo del cupon: ")

    validaciones =
      []
      |> validar_longitud(codigo_cupon)
      |> validar_mayuscula(codigo_cupon)
      |> validar_digitos(codigo_cupon)
      |> validar_espacios(codigo_cupon)

    resultado =
      case validaciones do
        [] ->
          "Cupon valido"
        _ ->
          "El código del cupón no cumple con los requisitos: #{Enum.join(validaciones, ", ")}"
        end
        IO.puts(resultado)
      end

      def validar_longitud(lista, codigo_cupon) do
        if String.length(codigo_cupon) >=10 do
          lista
        else
          lista ++ ["El código del cupón debe tener al menos 10 caracteres"]
        end
      end

      def validar_mayuscula(lista, codigo_cupon) do
        if String.match?(codigo_cupon, ~r/[A-Z]/) do
        lista
      else
        lista ++ ["El código del cupón debe contener al menos una letra mayúscula"]
      end
    end
    def validar_digitos(lista, codigo_cupon) do
      if String.match?(codigo_cupon, ~r/[0-9]/) do
        lista
      else
        lista ++ ["El código del cupón debe contener al menos un dígito"]
      end
    end
    def validar_espacios(lista, codigo_cupon) do
      if String.contains?(codigo_cupon, " ") do
        lista ++ ["El código del cupón no debe contener espacios"]
      else
        lista
      end
    end
  end

Cupon.main()
