defmodule Tiquete do

  # Calcular el total a pagar por un tiquete de avión, teniendo en cuenta el destino, si desea escoger silla, llevar maleta y contratar seguro.
  def main do
    destino = Util.leer_cadena("Ingrese su destino: ")

    silla =Util.leer_entero("desea escoger su silla (1 = si, 2 = no): ")
    maleta = Util.leer_entero("desea llevar maleta (1 = si, 2 = no): ")
    seguro = Util.leer_entero("desea contratar seguro (1 = si, 2 = no): ")

    total(destino, silla, maleta, seguro)

  end
# Tarifas para cada destino.
  def tarifa_base(:bogota), do: 80000
  def tarifa_base(:medellin), do: 90000
  def tarifa_base(:cartagena), do: 120000
  def tarifa_base(:san_andres), do: 200000

# Calculo del total a pagar segun las opciones seleccionadas.
  def total(destino, silla, maleta, seguro) do
    tb = tarifa_base(destino)
    s = if silla ==1, do: 15000, else: 0
    m = cond do
      destino == :san_andres -> 45000
      maleta == 1 -> 45000
      true -> 0
    end

    seg = if seguro == 1, do: 12000, else: 0

    total = tb + s + m + seg
    Util.imprimir("El total a pagar es: #{total}")
  end
end

Tiquete.main()
