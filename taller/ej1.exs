defmodule Ej1 do
  #def disponible_por_codigo(vuelos) do
  #vuelos
  #|> Enum.filter(&(&1.disponible))
  #|> Enum.map(& &1.codigo)
  #|> Enum.sort()
  #end

  #def vuelos_por_aerolinea(vuelos) do
  #vuelos
  #|> Enum.group_by(&(&1.aerolinea))
  #|> Enum.map(fn {aerolinea, lista} ->
  #    total =
  #      lista
  #      |> Enum.map(&(&1.pasajeros))
  #      |> Enum.sum()
  #  {aerolinea, total}
  #end)
  #end

  #def formato_vuelo(vuelos) do
  #vuelos
  #|> Enum.map(fn v ->
  #  horas = div(v.duracion, 60)
  #  minutos = rem(v.duracion, 60)
  #  min_string = String.pad_leading("#{minutos}", 2, "0")
  #  "#{v.codigo} - #{v.origen} -> #{v.destino}: #{horas}:#{min_string}m"
  #end)
#end

#def vuelo_precio_menor(vuelos, valor) do
  #vuelos
  #|> Enum.filter(&(&1.precio < valor))
  #|> Enum.map(fn v ->
  #    precio_final = v.precio * 0.9
  #    {v.codigo, "#{v.origen} -> #{v.destino}", precio_final}
  #  end)
  #|> Enum.sort_by(fn {_, _, precio} -> precio end)
#end

#def aerolineas_completas(vuelos) do
 # vuelos
  #|> Enum.group_by(&(&1.aerolinea))
  #|> Enum.filter(fn {_, lista} ->
   # categorias =
    #  lista
     # |> Enum.map(fn v ->
     #   cond do
     #     v.duracion < 60 -> :corto
     #     v.duracion >= 60 and v.duracion <= 120 -> :medio
     #     v.duracion > 120 -> :largo
     #   end
     # end)
     # Enum.member?(categorias, :corto) and
     # Enum.member?(categorias, :medio) and
     # Enum.member?(categorias, :largo)
    #end)
    #|> Enum.map(fn {aerolinea, _} -> aerolinea end)
#end

def rutas_rentables(vuelos) do
  vuelos
  |> Enum.filter(&(&1.disponible))
  |> Enum.map(fn v ->
    {"#{v.origen} → #{v.destino}", v.precio * v.pasajeros}
  end)
  |> Enum.group_by(fn {ruta, _} -> ruta end)
  |> Enum.map(fn {ruta, lista} -> {ruta, Enum.map(lista, fn {_, ingreso} -> ingreso end)
  |> Enum.sum()}
  end)
  |> Enum.sort_by(fn {_, ingreso} -> - ingreso end)
  |> Enum.take(3)
end
end

vuelos = [
  %{
    codigo: "AV201",
    aerolinea: "Avianca",
    origen: "BOG",
    destino: "MDE",
    duracion: 45,
    precio: 180_000,
    pasajeros: 120,
    disponible: true
  },
  %{
    codigo: "LA305",
    aerolinea: "Latam",
    origen: "BOG",
    destino: "CLO",
    duracion: 55,
    precio: 210_000,
    pasajeros: 98,
    disponible: true
  },
  %{
    codigo: "AV410",
    aerolinea: "Avianca",
    origen: "MDE",
    destino: "CTG",
    duracion: 75,
    precio: 320_000,
    pasajeros: 134,
    disponible: false
  },
  %{
    codigo: "VV102",
    aerolinea: "Viva Air",
    origen: "BOG",
    destino: "BAQ",
    duracion: 90,
    precio: 145_000,
    pasajeros: 180,
    disponible: true
  },
  %{
    codigo: "LA512",
    aerolinea: "Latam",
    origen: "CLO",
    destino: "CTG",
    duracion: 110,
    precio: 480_000,
    pasajeros: 76,
    disponible: false
  },
  %{
    codigo: "AV330",
    aerolinea: "Avianca",
    origen: "BOG",
    destino: "CTG",
    duracion: 135,
    precio: 520_000,
    pasajeros: 155,
    disponible: true
  },
  %{
    codigo: "VV215",
    aerolinea: "Viva Air",
    origen: "MDE",
    destino: "BOG",
    duracion: 50,
    precio: 130_000,
    pasajeros: 190,
    disponible: true
  },
  %{
    codigo: "LA620",
    aerolinea: "Latam",
    origen: "BOG",
    destino: "MDE",
    duracion: 145,
    precio: 390_000,
    pasajeros: 112,
    disponible: true
  },
  %{
    codigo: "AV505",
    aerolinea: "Avianca",
    origen: "CTG",
    destino: "BOG",
    duracion: 120,
    precio: 440_000,
    pasajeros: 143,
    disponible: false
  },
  %{
    codigo: "VV340",
    aerolinea: "Viva Air",
    origen: "BAQ",
    destino: "BOG",
    duracion: 85,
    precio: 160_000,
    pasajeros: 175,
    disponible: true
  }
]


IO.inspect(Ej1.rutas_rentables(vuelos))
