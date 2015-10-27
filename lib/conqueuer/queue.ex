defmodule Conqueuer.Queue do

  use GenServer

  # Public API ############

  def start_link(args, opts \\ []) do
    GenServer.start_link __MODULE__, args, opts
  end

  def empty(queue_pid) do
    GenServer.cast queue_pid, :empty
  end

  def enqueue(queue_pid, item) do
    GenServer.call queue_pid, {:enqueue, item}
  end

  def member?(queue_pid, item) do
    GenServer.call queue_pid, {:member?, item}
  end

  def next(queue_pid) do
    GenServer.call queue_pid, :next
  end

  def size(queue_pid) do
    GenServer.call queue_pid, :size
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
