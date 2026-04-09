defmodule Matriz do

  matriz = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ]

  def recorrer(matriz), do: recorrer(matriz, 0, length(matriz) - 1, 0)

  def recorrer([], _i, _j, acu), do: acu

  def recorrer([fila | resto], i, j, acu) do
    valor = obtener(fila, j)
    recorrer(resto, i + 1, j - 1, acu + valor)
  end
  def obtener([h | _], 0), do: h
  def ontener([_ | t ], i), do: obtener(t, i - 1)
end

IO.inspect(Matriz.recorrer(matriz))
