defmodule Competencia do

  # Puntos base
  def puntos_base(:facil), do: 100
  def puntos_base(:medio), do: 250
  def puntos_base(:dificil), do: 500

  # Multiplicador
  def multiplicador(1), do: 1.0
  def multiplicador(2), do: 0.75
  def multiplicador(3), do: 0.5

  # Calcular puntos por ronda
  def calcular_ronda({dificultad, :resuelto, intentos}) do
    base = puntos_base(dificultad)
    trunc(base * multiplicador(intentos))
  end

  def calcular_ronda({_dificultad, :no_resuelto, _intentos}) do
    -30
  end

  # Clasificación final
  def clasificacion(puntos, no_resueltas) do
    cond do
      no_resueltas == 2 ->
        :eliminado

      puntos >= 600 ->
        :oro

      puntos >= 400 ->
        :plata

      puntos >= 200 ->
        :bronce

      true ->
        :eliminado
    end
  end

  # Procesar competencia
  def evaluar(ronda1, ronda2) do
    puntos1 = calcular_ronda(ronda1)
    puntos2 = calcular_ronda(ronda2)

    total = puntos1 + puntos2

    no_resueltas =
      Enum.count([ronda1, ronda2], fn {_, r, _} -> r == :no_resuelto end)

    clasif = clasificacion(total, no_resueltas)

    %{
      ronda1: puntos1,
      ronda2: puntos2,
      total: total,
      no_resueltas: no_resueltas,
      clasificacion: clasif
    }
  end
end

r1 = {:facil, :resuelto, 1}
r2 = {:dificil, :resuelto, 1}

IO.inspect(Competencia.evaluar(r1, r2))
