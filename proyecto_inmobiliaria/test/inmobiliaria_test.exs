defmodule InmobiliariaTest do
  use ExUnit.Case

  alias Inmobiliaria.{UserManager, PropertyManager, MessageManager}

  describe "UserManager" do
    test "registra un nuevo usuario automáticamente" do
      {:ok, user} = UserManager.connect("testuser", "1234", "cliente")
      assert user.username == "testuser"
      assert user.role == "cliente"
    end

    test "valida contraseña incorrecta" do
      UserManager.connect("ana", "correcta", "cliente")
      {:error, reason} = UserManager.connect("ana", "incorrecta", "cliente")
      assert reason == "Contraseña incorrecta"
    end

    test "acumula puntos correctamente" do
      UserManager.connect("puntuado", "pass", "vendedor")
      UserManager.add_points("puntuado", 20)
      Process.sleep(50)  # esperar al cast
      {:ok, user} = UserManager.get_user("puntuado")
      assert user.points >= 20
    end
  end

  describe "PropertyManager" do
    test "publica una propiedad con ID generado" do
      {:ok, prop} = PropertyManager.publish(%{
        tipo: "casa",
        modalidad: "venta",
        ubicacion: "Armenia",
        precio: 300_000_000,
        habitaciones: 4,
        area: 180,
        propietario: "carlos"
      })
      assert prop.id != nil
      assert prop.estado == "disponible"
    end

    test "filtra por tipo" do
      PropertyManager.publish(%{tipo: "apartamento", modalidad: "arriendo",
        ubicacion: "Calarcá", precio: 1_200_000, habitaciones: 2, area: 60, propietario: "luis"})
      results = PropertyManager.search([{:tipo, "apartamento"}])
      assert Enum.any?(results, &(&1.tipo == "apartamento"))
    end
  end

  describe "MessageManager" do
    test "envía y recupera mensajes" do
      PropertyManager.publish(%{tipo: "lote", modalidad: "venta",
        ubicacion: "Salento", precio: 50_000_000, habitaciones: 0, area: 500, propietario: "pedro"})
      props = PropertyManager.list_all()
      prop = List.last(props)
      MessageManager.send_message(prop.id, "cliente1", "¿Sigue disponible?")
      msgs = MessageManager.get_messages(prop.id)
      assert length(msgs) > 0
      assert List.first(msgs).from == "cliente1"
    end
  end
end
