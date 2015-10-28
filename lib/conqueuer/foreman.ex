defmodule Conqueuer.Foreman do

  use GenServer

  require Logger

  alias Conqueuer.Util

  # Public API ##########

  def start_link( args \\ [], opts \\ [] ) do
    GenServer.start_link __MODULE__, args, opts
  end

  def work_arrived( foreman ) do
    GenServer.cast foreman, :work_arrived
  end

  def finished( foreman, worker ) do
    GenServer.cast foreman, {:finished, worker}
  end

  # Private API ##########

  def init( args ) do
    {:ok, name} = Keyword.fetch( args, :name )

    {pool_name, queue_name} = Util.infer_foreman_collaborator_names( name )

    {:ok, %{pool_name: pool_name,
            queue_name: queue_name}}
  end

  def handle_cast( :work_arrived, state ) do
    #debug "work arrived"

    %{pool_name: pool,
      queue_name: queue} = state

    drain_queue pool, queue

    {:noreply, state}
  end

  def handle_cast( {:finished, worker}, state ) do
    #debug "work finished, checking worker in"

    %{pool_name: pool,
      queue_name: queue} = state

    :poolboy.checkin( pool, worker )
    #debug "Poolboy status: #{inspect :poolboy.status( pool )}"

    drain_queue pool, queue

    {:noreply, state}
  end

  # Private ##########

  defp drain_queue( pool, queue ) do
    #debug "draining queue"

    case :poolboy.status( pool ) do
      {:ready, _, _, _} ->
        do_work pool, queue

      {:overflow, _, _, _} ->
        do_work pool, queue

      {:full, _, _, _} ->
        #warn "pool exhausted, stopping drain"
        :exhausted
    end
  end

  defp do_work( pool, queue ) do
    case queue_next( queue ) do
      {:ok, args} ->
        worker = :poolboy.checkout( pool )
        GenServer.cast worker, {:work, self, args}
        drain_queue pool, queue

      :empty ->
        #debug "queue empty, stopping drain"
        :empty
    end
  end

  defp queue_next( queue ) do
    Conqueuer.Queue.next queue
  end

  defp debug( msg ), do: Logger.debug "#{log_label} #{msg}"
  defp warn( msg ),  do: Logger.warn "#{log_label} #{msg}"

  defp log_label, do: "[#{Util.registered_name self}]"

end
