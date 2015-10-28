defmodule Conqueuer do

  alias Conqueuer.Util

  def work( name, args \\ nil ) do
    {foreman_name, queue_name} = Util.infer_conqueuer_collaborator_names( name )

    Conqueuer.Queue.enqueue( queue_name, args )
    Conqueuer.Foreman.work_arrived( foreman_name )
  end

end
