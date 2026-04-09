defmodule Potencia do
  def potencia(n, b) when n == 1, do: true
  def potencia(n, b) when n < b, do: false
  def potencia(n, b) when rem(n, b) != 0, do: false

  def potencia(n, b) do
    potencia(div(n, b), b)
  end
end

IO.puts Potencia.potencia(16, 2)
