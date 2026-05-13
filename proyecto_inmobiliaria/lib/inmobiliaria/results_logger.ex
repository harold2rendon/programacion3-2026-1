defmodule Inmobiliaria.ResultsLogger do
  @results_file "data/results.log"

  def log_operation(client, responsable, property, operacion) do
    date = Date.utc_today() |> Date.to_string()
    line =
      "#{date}; cliente=#{client}; responsable=#{responsable}; " <>
      "propiedad=#{property.id}; operacion=#{operacion}; " <>
      "ubicacion=#{property.ubicacion}; precio=#{property.precio}; status=Completada\n"

    File.mkdir_p!(Path.dirname(@results_file))
    File.write!(@results_file, line, [:append])
  end

  def read_all do
    case File.read(@results_file) do
      {:ok, content} -> content
      {:error, _}    -> ""
    end
  end
end
