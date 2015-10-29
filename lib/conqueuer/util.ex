defmodule Conqueuer.Util do

  def infer_collaborator_names( name ) do
    {infer_foreman_name( name ), infer_pool_name( name ), infer_queue_name( name )}
  end

  def infer_conqueuer_collaborator_names( name ) do
    {infer_foreman_name( name ), infer_queue_name( name )}
  end

  def infer_foreman_collaborator_names( name ) do
    {infer_pool_name( name ), infer_queue_name( name )}
  end

  def infer_foreman_name( name ) do
    (infer_base_name( name ) <> "Foreman") |> String.to_atom
  end

  def infer_pool_name( name ) do
    name
  end

  def infer_queue_name( name ) do
    (infer_base_name( name ) <> "Queue") |> String.to_atom
  end

  defp infer_base_name( name ) do
    name
    |> Atom.to_string
    |> Inflex.camelize
  end

  # TODO move to external project

  def pid_as_string do
    pid_to_string self
  end

  def pid_to_string( pid ) do
    Kernel.inspect( pid )
  end

  def ip_to_binary( ip_tuple ) do
    ip_tuple
    |> Tuple.to_list
    |> Enum.join "."
  end

  def ip_to_tuple( ip_str ) do
    ip_str
    |> String.split( "." )
    |> Enum.map( &(String.to_integer( &1 )))
    |> List.to_tuple
  end

  def registered_name( pid ) do
    Process.info( self )[:registered_name]
  end

end
