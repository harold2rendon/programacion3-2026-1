defmodule Hotel do

# Calcular el costo total de una reserva en un hotel, teniendo en cuenta el número de noches, el tipo de cliente (frecuente, corporativo, ocasional) y si es temporada alta o baja.
  def main do
    noches = Util.leer_entero("Ingrese el número de noches: ")

    tipo_cliente = ("Ingrese el tipo de cliente (frecuente, corporativo, ocasional): ")
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> String.to_atom()
        recargo_temporada = Util.leer_entero("Ingrese la temporada (1 = temporada alta, 2 = temporada baja): ")

        {tarifa_base, subtotal, descuento, recargo_temporada, total} =
          calcular(noches, tipo_cliente, recargo_temporada)

          Util.imprimir("Tarifa: #{tarifa_base}")
          Util.imprimir("Subtotal: #{subtotal}")
          Util.imprimir("Descuento: #{descuento}")
          Util.imprimir("Recargo: #{recargo_temporada}")
          Util.imprimir("Total a pagar: #{total}")
        end

# Tarifas según el número de noches.
def tarifa(noches) when noches <= 2, do: 120000
def tarifa(noches) when noches >= 3 and noches <= 5, do: 100000
def tarifa(noches) when noches > 5, do: 85000

# Descuentos según el tipo de cliente.
def descuento(:frecuente, subtotal), do: div(subtotal * 20, 100)
def descuento(:corporativo, subtotal), do: div(subtotal * 15, 100)
def descuento(:ocasional, _), do: 0
def descuento(_, _), do: 0

# Cálculo del costo total de la reserva.
def calcular(noches, tipo_cliente, recargo_temporada) do
  tarifa_base = tarifa(noches)
  subtotal = tarifa_base * noches
  descuento = descuento(tipo_cliente, subtotal)
  subtotal2 = subtotal - descuento

  recargo_temporada =
    cond do
      recargo_temporada == 1 -> div(subtotal2 * 20, 100)
      recargo_temporada == 2 -> 0
      true -> 0
    end

    total = subtotal2 + recargo_temporada
    {tarifa_base, subtotal, descuento, recargo_temporada, total}
  end
end

Hotel.main()
