defmodule Pilas do 
  def numero(n) when n >= 0 do
    div(n * (n + 1), 2)
  end
end
IO.puts(Pilas.numero(4))
