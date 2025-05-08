defmodule TaskScheduler do
  use Supervisor

  def start_link(_args) do
    IO.puts("Scheduler has started!")
    Supervisor.start_link(__MODULE__, :ok, name: :taskscheduler)
  end

  def init(_init_args) do
    children = [TaskSupervisor]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
