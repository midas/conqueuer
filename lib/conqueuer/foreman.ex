defmodule Conqueuer.Foreman do
  @moduledoc ~S"""
  The foreman is responsible for coordinating the arrival, performance and
  finishing of work.

  When `:work_arrived` the foreman begins to drain the queue and continues until
  either the queue is empty or the worker pool is exhausted at which point it
  stops draining.  When a worker is `:finished` the foreman checks the worker
  back into the worker queue and begins to drain the queue again.

  You do not have to define a foreman, only add a registered foreman process
  with the correct name to your supervision tree.

  Given a work queue named `:resolvers`:

      defmodule MyApp do
        use Application

        def start(_type, _args) do
          import Supervisor.Spec, warn: false

          children = [
            ...
            worker(Conqueuer.Foreman, [[name: :resolvers], [name: :ResolversForeman]])
          ]

          opts = [ strategy: :one_for_one, name: MyApp.Supervisor ]
          Supervisor.start_link(children, opts)
        end
      end
  """

  use GenServer

  require Logger

  alias Conqueuer.Util

  # Public API ##########

  @doc """
  Starts the Foreman.
  """
  def start_link( args \\ [], opts \\ [] ) do
    GenServer.start_link __MODULE__, args, opts
  end

  @doc """
  Notifies the Foreman work has arrived.
  """
  def work_arrived( foreman ) do
    GenServer.cast foreman, :work_arrived
  end

  @doc """
  Notifies the Foreman work has finished.
  """
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
