defmodule TaskSupervisor do
  use Supervisor

  @doc """
    Supervisor will manage all the child processes!
  """

  def start_link(_arg) do 
    IO.puts("Task supervisor has started!")
    Supervisor.start_link(__MODULE__, :ok, name: :tasksupervisor)
  end

  def init(_init_args) do
    children = [{DynamicSupervisor, name: :dynamictaskmanager}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
