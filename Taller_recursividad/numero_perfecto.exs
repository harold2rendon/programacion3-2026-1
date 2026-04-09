defmodule NumeroPerfecto do
  def es_perfecto?(n) do
    suma_divisores(n, 1, 0) == n
  end

  defp suma_divisores(n, divisor, acu) when divisor == n, do: acu

  defp suma_divisores(n, divisor, acu) do
    if rem(n, divisor) == 0 do
      suma_divisores(n, divisor + 1, acu + divisor)
    else
      suma_divisores(n, divisor + 1, acu)
    end
  end
end


IO.puts NumeroPerfecto.es_perfecto?(7)
