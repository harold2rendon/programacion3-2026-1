defmodule NQueens do
  def solve(n) do
    solve(n, 0, [], [])
  end

  # Caso base: Si la columna actual es igual a N, encontramos una solución
  defp solve(n, col, queens, solutions) when col == n do
    [queens | solutions]
  end

  # Intentar colocar una reina en cada fila de la columna actual
  defp solve(n, col, queens, solutions) do
    0..(n - 1)
    |> Enum.reduce(solutions, fn row, acc ->
      if safe?(row, col, queens) do
        solve(n, col + 1, [{row, col} | queens], acc)
      else
        acc
      end
    end)
  end

  # Verificar si la posición (row, col) es segura
  defp safe?(r1, c1, queens) do
    Enum.all?(queens, fn {r2, c2} ->
      r1 != r2 && # Misma fila
      abs(r1 - r2) != abs(c1 - c2) # Misma diagonal
    end)
  end
end

# Uso:
IO.inspect(NQueens.solve(4))
