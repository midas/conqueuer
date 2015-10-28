defmodule ConqueuerSpec.SomethingWorkerPool do

  use Conqueuer.Pool, name: :something_workers,
                      worker: ConqueuerSpec.SomethingWorker

end
