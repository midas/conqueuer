defmodule Conqueuer do
  @moduledoc ~S"""
  Conqueuer (pronounced like conquer) is a non-persistent Elixir work queue.

  ## Architecture

  In conqueuer, there are 3 collaborators involved in the work off process. The
  work is initially queued to a [queue](Conqueuer.Queue.html) executing as a
  registered (or named) process.  Immediately after the work is queued, the
  [foreman](Conqueuer.Foreman.html) executing as a registered process is notified
  that `:work_arrived`.  At this point, the foreman drains the queue.

  The queue draining process starts with an attempt to check out a worker from
  the associated [poolboy](https://github.com/devinus/poolboy) worker pool. If a
  worker is available it is passed the `args` and the work is performed.  If a
  worker is not available, the foreman abandons draining the queue and waits for
  work to be `:finished` or `:work_arrived`, at which time the draining starts
  again.

  Once a worker has performed the work, it notifies it's associated foreman it is
  `:finished`.  The foreman checks the worker back into poolboy and begins to
  drain the queue.

  Because of the collaboration of multiple processes to achieve the results, the
  registered name of the processes is important so that each process can
  discover its collaborators.  At this time Conqueuer does not have helpers to
  generate the supervisor and worker specs for you, thus great care should be taken
  in the naming.

  ## Naming Conventions

  Given you desire a worker pool named `:resolvers` the convention for the collaborator
  names is:

  * Foreman process: `:ResolversForeman`
  * Poolboy queue: `:resolvers`
  * Poolboy supervisor process: `:ResolversPoolSupervisor`
  * Queue process: `:ResolversQueue`

  ## Example

  Again, given you desire a worker pool named `:resolvers`.

  Define a [pool](Conqueuer.Pool.html):

      defmodule MyApp.ResolversPoolSupervisor do
        use Conqueuer.Pool, name: :resolvers,
                            worker: MyApp.ResolverWorker,
                            size: 20,
                            max_overflow: 10
      end

  Define a [worker](Conqueuer.Worker.html):

      defmodule MyApp.ResolverWorker do
        use Conqueuer.Worker

        def perform({arg1, arg2}) do
          # do some work
        end
      end

  Add the processes to your supervision tree:

      defmodule MyApp do
        use Application

        def start(_type, _args) do
          import Supervisor.Spec, warn: false

          children = Conqueuer.child_specs(:resolvers, MyApp.ResolversPoolSupervisor)

          opts = [strategy: :one_for_one, name: Test.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end

  Submit some work:

      Conqueuer.work(:resolvers, {:hello, "world"})

  Enjoy!
  """

  alias Conqueuer.Util

  @doc """
  Queues the `args` for the work to be performed to the `name` worker queue.
  """
  def work( name, args \\ nil ) do
    {foreman_name, queue_name} = Util.infer_conqueuer_collaborator_names(name)

    Conqueuer.Queue.enqueue(queue_name, args)
    Conqueuer.Foreman.work_arrived(foreman_name)
  end

  @doc """
  Generates the child process specs for a Conqueuer work queue.  Expects the
  name of the pool and module of the pool supervisor.

  Manual way:

      children = [
        supervisor(MyApp.ResolversPoolSupervisor, [[], [name: :ResolversPoolSupervisor]]),
        worker(Conqueuer.Queue, [[], [name: :ResolversQueue]]),
        worker(Conqueuer.Foreman, [[name: :resolvers], [name: :ResolversForeman]])
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]
      Supervisor.start_link(children, opts)

  Using the helper:

      children = Conqueuer.child_specs( :resolvers, Test.PoolSupervisor )

      opts = [strategy: :one_for_one, name: Test.Supervisor]
      Supervisor.start_link(children, opts)
  """
  def child_specs(pool_name, pool_supervisor_module) do
    import Supervisor.Spec, warn: false

    {foreman, pool, pool_supervisor, queue} = Util.infer_collaborator_names(pool_name)

    [
      supervisor(pool_supervisor_module, [[], [name: pool_supervisor]]),
      worker(Conqueuer.Queue, [[], [name: queue]]),
      worker(Conqueuer.Foreman, [[name: pool_name], [name: foreman]])
    ]
  end

end
