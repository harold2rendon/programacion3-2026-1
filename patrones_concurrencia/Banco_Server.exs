defmodule CajeroSemaforo do
  use GenServer

  def start_link(cabinas) do
    GenServer.start_link(__MODULE__, cabinas, name: __MODULE__)
  end

  def usar_cajero(cliente, operacion) do
    IO.puts("#{cliente} llegó y espera turno...")
    :ok = adquirir()

    try do
      IO.puts("#{cliente} ingresó a una cabina.")
      operacion.()
    after
      IO.puts("#{cliente} terminó y liberó la cabina.\n")
      liberar()
    end
  end

  defp adquirir, do: GenServer.call(__MODULE__, :adquirir, :infinity)
  defp liberar,  do: GenServer.cast(__MODULE__, :liberar)

  @impl true
  def init(cabinas), do: {:ok, %{max: cabinas, ocupadas: 0, cola: :queue.new()}}

  @impl true
  def handle_call(:adquirir, _from, %{ocupadas: o, max: max} = state) when o < max do
    {:reply, :ok, %{state | ocupadas: o + 1}}
  end

  @impl true
  def handle_call(:adquirir, from, %{cola: cola} = state) do
    {:noreply, %{state | cola: :queue.in(from, cola)}}
  end

  @impl true
  def handle_cast(:liberar, %{ocupadas: o, cola: cola} = state) do
    case :queue.out(cola) do
      {{:value, siguiente}, resto} ->
        GenServer.reply(siguiente, :ok)
        {:noreply, %{state | cola: resto}}
      {:empty, _} ->
        {:noreply, %{state | ocupadas: o - 1}}
    end
  end
end

defmodule Banco do
  def abrir do
    {:ok, _} = CajeroSemaforo.start_link(2)

    clientes = ["Ana", "Luis", "María", "Pedro", "Sofía"]

    clientes
    |> Enum.map(fn nombre ->
      Task.async(fn ->
        CajeroSemaforo.usar_cajero(nombre, fn ->
          segundos = Enum.random(1..3)
          Process.sleep(segundos * 1_000)
          IO.puts("  -> #{nombre} retiró dinero en #{segundos}s.")
        end)
      end)
    end)
    |> Task.await_many(:infinity)

    IO.puts("Todos los clientes fueron atendidos.")
  end
end

Banco.abrir()
