defmodule Mensaje do
  def main do
    # Se genera el mensaje de bienvenida y se muestra utilizando la función mostrar_mensaje
    "Bienvenidos a la empresa Once Ltda"
    |> Util.mostrar_mensaje()
  end
end

Mensaje.main()
