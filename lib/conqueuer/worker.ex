defmodule Conqueuer.Worker do
  @moduledoc """
  Use this mixin to define a worker. A worker must define a perform function
  that is run as part of a background process.

      defmodule MyApp.SomeWorker do
        use Conqueuer.Worker

        def perform do
        end
      end

  To provide a single parameter:

      defmodule MyApp.SomeWorker do
        use Conqueuer.Worker

        def perform(param) do
        end
      end

  For more than one parameter, use a tuple.

      defmodule MyApp.SomeWorker do
        use Conqueuer.Worker

        def perform({param1, param2}) do
        end
      end
  """

  defmacro __using__(_) do
    quote do
      use GenServer

      def start_link( args \\ [], opts \\[] ) do
        GenServer.start_link __MODULE__, args, opts
      end

      def handle_cast( {:work, foreman, args}, state ) do
        if args == nil do
          perform
        else
          perform args
        end

        send foreman, {:finished, self}

        {:noreply, state}
      end

      def perform do
        raise "You must define a perform/0 function in your worker"
      end

      def perform(_) do
        raise "You must define a perform/1 function in your worker"
      end

      defoverridable [ perform: 0, perform: 1 ]
    end
  end

end
