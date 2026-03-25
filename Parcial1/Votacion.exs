defmodule Votacion do

  def validar_voto({candidato, codigo, jornada}) do
    errores = []

    errores =
      errores
      |> validar_candidato(candidato)
      |> validar_codigo(codigo)
      |> validar_jornada(jornada)

    case errores do
      [] -> {:ok, "Voto registrado"}
      _ -> {:error, errores}
    end
  end

  # -------------------------
  # VALIDACIONES
  # -------------------------

  # Candidato
  defp validar_candidato(errores, candidato)
       when candidato in [:candidato_a, :candidato_b, :candidato_c] do
    errores
  end

  defp validar_candidato(errores, _candidato) do
    ["Candidato inválido" | errores]
  end

  # Código estudiante
  defp validar_codigo(errores, codigo) when is_binary(codigo) do
    cond do
      String.length(codigo) != 8 ->
        ["El código debe tener 8 dígitos" | errores]

      not String.match?(codigo, ~r/^\d+$/) ->
        ["El código debe ser numérico" | errores]

      true ->
        errores
    end
  end

  defp validar_codigo(errores, _codigo) do
    ["El código debe ser un string" | errores]
  end

  # Jornada
  defp validar_jornada(errores, jornada)
       when jornada in [:diurna, :nocturna] do
    errores
  end

  defp validar_jornada(errores, _jornada) do
    ["Jornada inválida" | errores]
  end
end

IO.inspect(Votacion.validar_voto({:candidato_a, "12345678", :diurna}))
