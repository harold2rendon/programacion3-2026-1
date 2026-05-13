defmodule Inmobiliaria.PropertySupervisor do
  # Ya no necesitas 'use Supervisor' ni 'init' aquí si usamos el DynamicSupervisor directo

  def start_property(property) do
    DynamicSupervisor.start_child(
      Inmobiliaria.DynamicPropertySupervisor,
      {Inmobiliaria.Property, property}
    )
  end

  def stop_property(property_id) do
    case Registry.lookup(Inmobiliaria.PropertyRegistry, property_id) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(Inmobiliaria.DynamicPropertySupervisor, pid)
      [] ->
        {:error, :not_found}
    end
  end
end
