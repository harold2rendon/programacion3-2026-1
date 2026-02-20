Code.require_file ("util.ex")

defmodule Mensaje do
  def main do
    "Bienvenidos a la empresa Once Ltda"
    |> Util.mostrar_mensaje()
  end
end

Mensaje.main()
