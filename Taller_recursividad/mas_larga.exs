defmodule Cadenas do
  def mas_larga ([h | t]) do
    mas_larga(t, h)
  end

  defp mas_larga([], mas_larga), do: mas_larga

  defp mas_larga([h | t], mas_larga) do
    if String.length(h) > String.length(mas_larga) do
      mas_larga(t, h)
    else
      mas_larga(t, mas_larga)
    end
  end
end

IO.puts Cadenas.mas_larga(["hola", "mundo", "programacion", "elixir" , "lenguaje de programacion funcional"])
