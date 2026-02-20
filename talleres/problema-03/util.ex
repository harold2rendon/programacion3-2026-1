defmodule Util do
  def mostrar_mensaje(mensaje) do
    System.cmd("java",["-cp", ".", "Mensaje", mensaje])
  end
  # Para texto
  def ingresar(mensaje, :texto) do
    IO.gets(mensaje)
    |> String.trim()
  end

  # Para entero
  def ingresar(mensaje, :entero) do
    try do
      mensaje
      |> ingresar(:texto)
      |> String.to_integer()
    rescue
      ArgumentError ->
        IO.puts("Error, se espera que ingrese un número entero")
        ingresar(mensaje, :entero)
    end
  end

  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end
end
