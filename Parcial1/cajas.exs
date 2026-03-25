defmodule Distribucion do

  def calcular(productos) when productos <= 0 or productos > 1000 do
    {:error, "Cantidad no permitida"}
  end

  def calcular(productos) when rem(productos, 10) != 0 do
    {:error, "Cantidad no permitida"}
  end

  def calcular(productos) do
    grandes = div(productos, 100)
    resto1 = rem(productos, 100)

    medianas = div(resto1, 50)
    resto2 = rem(resto1, 50)

    pequenas = div(resto2, 10)

    {:ok, {pequenas, medianas, grandes}}
  end
end

IO.inspect(Distribucion.calcular(150))
