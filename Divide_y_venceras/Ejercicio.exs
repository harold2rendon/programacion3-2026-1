defmodule SumaDyV do
  def suma([]), do: 0
  def suma([x]), do: x

  def suma(lista) do
    mitad = div(length(lista), 2)
    {izq, der} = Enum.split(lista, mitad)
    suma(izq) + suma(der)
  end
end

IO.inspect(SumaDyV.suma([1, 2, 3, 4]))
# Debería imprimir 10
