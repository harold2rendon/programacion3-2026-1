defmodule Util do
  def leer_entero(mensaje) do
    IO.gets(mensaje)
    |> String.trim()
    |> String.to_integer()
  end

  def leer_cadena(mensaje) do
    IO.gets(mensaje)
    |> String.trim()
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.to_atom()
  end

  def imprimir(mensaje) do
    IO.puts(mensaje)
  end

end
