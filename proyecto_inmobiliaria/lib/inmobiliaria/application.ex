defmodule Inmobiliaria.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # 1. El Registro es la base para encontrar los procesos de propiedades
      {Registry, keys: :unique, name: Inmobiliaria.PropertyRegistry},

      # 2. El Supervisor Dinámico para los procesos individuales
      {DynamicSupervisor, name: Inmobiliaria.DynamicPropertySupervisor, strategy: :one_for_one},

      # 3. Los Managers del sistema
      Inmobiliaria.UserManager,
      Inmobiliaria.PropertyManager,
      Inmobiliaria.MessageManager,
      Inmobiliaria.SessionManager
    ]

    opts = [strategy: :one_for_one, name: Inmobiliaria.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
