defmodule Vocales do
  def contar_lista(cadena) do
    contar_lista(cadena, 0)
  end

  defp contar_lista(<<>>, acu), do: acu

  defp contar_lista(<<h::utf8, t::binary>>, acu) do
  if es_vocal?(h) do
      contar_lista(t, acu + 1)
    else
      contar_lista(t, acu)
    end
  end

  defp es_vocal?(h) do
    h in ~c'aeiouAEIOU'
  end
end


IO.puts Vocales.contar_lista("noche")
