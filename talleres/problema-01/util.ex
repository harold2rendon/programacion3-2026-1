defmodule Util do
  # Función para mostrar el mensaje utilizando un comando del sistema
  def mostrar_mensaje(mensaje) do
    System.cmd("java",["-cp", ".", "Mensaje", mensaje])
  end
end
