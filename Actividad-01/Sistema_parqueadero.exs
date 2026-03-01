defmodule Parqueadero do

# Calcular la tarifa de un parqueadero y aplicar descuentos si es necesario.
  def tarifa do
    horas =
      IO.gets("Ingrese las horas que estuvo estacionado: ")
      |> String.trim()
      |> String.to_integer()

    cliente =
      IO.gets("Ingrese el tipo de cliente (1 = frecuente, 2 = regular): ")
      |> String.trim()
      |> String.to_integer()

    vehiculo =
      IO.gets("Ingrese el tipo de vehículo (1 = electrico, 2 = convecional): ")
      |> String.trim()
      |> String.to_integer()

    dia =
      IO.gets("Ingrese el día (1 = fin de semana, 2 = entre semana): ")
      |> String.trim()
      |> String.to_integer()

    # Calcular la tarifa base
    base =
      cond do
        horas <= 2 -> 3000
        horas <= 5 -> 3000 + (horas - 2) * 2500
        horas <= 8 -> 3000 + 3 * 2500 + (horas - 5) * 2000
        true -> 18000
      end

    # Aplicar descuento por tipo de cliente
    descuento_por_cliente =
      case cliente do
      1  -> base * 0.85
      _ -> base
      end

    # Aplicar descuento por tipo de vehículo
    descuento_por_vehiculo =
      case vehiculo do
      1 -> descuento_por_cliente * 0.90
      _ -> descuento_por_cliente
      end
      
    # Aplicar descuento por día
    total =
      case dia do
      1 -> descuento_por_vehiculo * 0.90
      _ -> descuento_por_vehiculo
    end

    IO.puts("Total antes de descuentos: #{base} ")
    IO.puts("Tota con descuentos: #{trunc(total)} ")

    {base, trunc(total)}
  end
end

Parqueadero.tarifa()
