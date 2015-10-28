defmodule Conqueuer.Queue do

  use GenServer

  # Public API ############

  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link __MODULE__, args, opts
  end

  def empty( queue ) do
    GenServer.cast queue, :empty
  end

  def enqueue( queue , item) do
    GenServer.call queue, {:enqueue, item}
  end

  def member?( queue , item) do
    GenServer.call queue, {:member?, item}
  end

  def next( queue ) do
    GenServer.call queue, :next
  end

  def size( queue ) do
    GenServer.call queue, :size
  end

  # Private API ############

  def init( args ) do
    {:ok, %{queue: :queue.new}}
  end

  def handle_cast(:empty, state) do
    {:noreply, %{state | queue: :queue.new}}
  end

  def handle_call({:enqueue, item}, _from, state) do
    %{queue: queue} = state
    queue = :queue.in(item, queue)

    {:reply, :ok, %{state | queue: queue}}
  end

  def handle_call({:member?, item}, _from, %{queue: queue} = state) do
    {:reply, :queue.member(item, queue), state}
  end

  def handle_call(:next, _from, %{queue: queue} = state) do
    case :queue.out(queue) do
      {{:value, item}, queue} ->
        {:reply, {:ok, item}, %{state | queue: queue}}
      {:empty, {[], []}} ->
        {:reply, :empty, state}
    end
  end

  def handle_call(:size, _from, %{queue: queue} = state) do
    {:reply, :queue.len(queue), state}
  end

end
