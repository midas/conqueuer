defmodule Conqueuer.Worker do
  @moduledoc """
  Use this mixin to define a worker. A worker must define a perform function
  that is run as part of a background process.

      defmodule MyApp.ResolverWorker do
        use Conqueuer.Worker

        def perform(state) do
        end
      end

  To provide a single parameter:

      defmodule MyApp.ResolverWorker do
        use Conqueuer.Worker

        def perform(param, state) do
        end
      end

  For more than one parameter, use a tuple.

      defmodule MyApp.ResolverWorker do
        use Conqueuer.Worker

        def perform({param1, param2}, state) do
        end
      end
  """

  defmacro __using__(_) do
    quote do
      use GenServer

      def start_link( args \\ [], opts \\[] ) do
        GenServer.start_link __MODULE__, args, opts
      end

      def init(state) do
        {:ok, state}
      end

      def handle_cast( {:work, foreman, args}, state ) do
        if args == nil do
          perform state
        else
          perform args, state
        end

        Conqueuer.Foreman.finished foreman, self

        {:noreply, state}
      end

      def perform(_) do
        raise "You must define a perform/1 function in your worker"
      end

      def perform(_,_) do
        raise "You must define a perform/1 function in your worker"
      end

      defoverridable [ perform: 1, perform: 2 ]
    end
  end

end
