defmodule EntradaReales do
  def main() do
    valor_producto =
      "Ingrese el valor del producto: "
      |> Util.ingresar(:entero)

    porcentaje_descuento =
      "Ingrese el porcentaje de descuento: "
      |> Util.ingresar(:real)

    valor_descuento =
      calcular_valor_descuento(valor_producto, porcentaje_descuento)

    valor_final =
      calcular_valor_final(valor_producto, valor_descuento)

    mensaje =
      generar_mensaje(valor_descuento, valor_final)

    Util.mostrar_mensaje(mensaje)
  end

  defp calcular_valor_descuento(valor_producto, porcentaje_descuento) do
    valor_producto * (porcentaje_descuento / 100)
  end

  defp calcular_valor_final(valor_producto, valor_descuento) do
    valor_producto - valor_descuento
  end

defp generar_mensaje(valor_descuento, valor_final) do
  valor_descuento =
    :erlang.float_to_binary(valor_descuento, decimals: 2)

  valor_final =
    :erlang.float_to_binary(valor_final, decimals: 2)

  "Valor de descuento de $#{valor_descuento} y el valor final $#{valor_final}"
end

end

EntradaReales.main()
