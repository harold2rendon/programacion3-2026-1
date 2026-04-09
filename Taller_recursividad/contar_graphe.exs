defmodule Vocales do
  def contar_vocales(cadena) do
    cadena
    |> String.graphemes()
    |> contar_lista(0)
  end

  defp contar_lista([], acu), do: acu

  defp contar_lista([h | t], acu) when h in ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"] do
    contar_lista(t, acu + 1)
  end

  defp contar_lista([_h | t], acu) do
    contar_lista(t, acu)
  end
end

IO.puts Vocales.contar_vocales("el murcielago vuela en la noche")
