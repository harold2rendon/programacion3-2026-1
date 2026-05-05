defmodule Semaforo do

  def nuevo(max) do
    spawn(fn -> loop(max, 0, []) end) #cabinas, ocupadas, cola
  end

  def usar(pid, fun) do
    send(pid, {:adquirir, self()}) # el que quiere entrar se identifica con su PID (dirección)

    receive do
      :ok -> :ok # bloquea hasta que lo dejen entrar
    end

    try do
      fun.() # usa el cajero
    after
      send(pid, :liberar) # avisa que se fue
    end
  end

  defp loop(max, ocupadas, cola) do
    receive do

      # si hay cajero, entra uno
      {:adquirir, from} when ocupadas < max ->
        send(from, :ok)
        loop(max, ocupadas + 1, cola)

      # si no hay cajero, se pone en la cola
      {:adquirir, from} ->
        loop(max, ocupadas, cola ++ [from])

      #aviso de que alguien salio
      :liberar ->
        case cola do
          [siguiente | resto] ->
            send(siguiente, :ok) # deja entrar al siguiente de la cola
            loop(max, ocupadas, resto)

          [] ->
            loop(max, ocupadas - 1, []) # si no hay nadie en la cola, libera un cajero
        end
    end
  end
end

defmodule Banco do
  def abrir do
    sem = Semaforo.nuevo(2)

    ["Ana", "Luis", "María", "Pedro", "Sofía"]
    |> Enum.map(fn nombre ->
      Task.async(fn ->
        Semaforo.usar(sem, fn ->
          IO.puts("#{nombre} usando el cajero...")
          Process.sleep(Enum.random(1..2) * 1000)
          IO.puts("#{nombre} terminó.")
        end)
      end)
    end)
    |> Task.await_many(:infinity)
  end
end

Banco.abrir()
