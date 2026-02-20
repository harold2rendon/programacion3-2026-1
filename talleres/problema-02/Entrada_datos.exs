defmodule EntradaDatos do
  def main() do
    # Aquí se solicita el nombre del empleado, se genera el mensaje de bienvenida y se muestra utilizando la función mostrar_mensaje
    "Ingrese nombre del empleado: "
    |> Util.ingresar(:texto)
    |> generar_mensaje()
    |> Util.mostrar_mensaje()
  end

  # Función privada para generar el mensaje de bienvenida
  defp generar_mensaje(nombre) do
   "Bienvenido #{nombre} a la empresa Once Ltda"
  end
end

EntradaDatos.main()
