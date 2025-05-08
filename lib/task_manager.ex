defmodule TaskManager do
  alias IO.ANSI, as: Color
  use GenServer

  @spec start_link(atom()) :: {{any()}}
  def start_link(task_servername) do
    IO.puts("Task manager is starting for #{task_servername}...")
    GenServer.start_link(__MODULE__, %{tasks: []}, name: task_servername)
  end
  
  def showTasks(pid) when is_atom(pid) do
    GenServer.call(pid, :showtasks)
  end

  def start_child(name) when is_atom(name) do
    DynamicSupervisor.start_child(:dynamictaskmanager, {TaskManager, name})
  end
    
  @spec addtask(atom(), map()) :: {{any()}}
  def addtask(pid, task_inst) do
    if Map.has_key?(task_inst, :task) == true and Map.has_key?(task_inst, :status) == true do
      GenServer.cast(pid, {:addtask, task_inst})
    else
      IO.puts("You must provide 'task' and 'status' values!") 
    end
  end

  def setTaskStatus(pid, task_id, status) do
    GenServer.cast(pid, {:setstatus, {:ok, status, task_id}})
  end

  def child_spec(name) do
    %{
      id: __MODULE__,
      restart: :temporary,
      shutdown: 5000,
      start: {__MODULE__, :start_link, [name]},
      type: :worker
    }
  end
  
  # handle_call will help us read the buffer in state!
  @impl true
  def handle_call(:showtasks, _from, state) do
    if length(state.tasks) == 0 do
      IO.puts("#{Color.green}No tasks yet!#{Color.white}")
      {:reply, :ok, state}
    else
      state.tasks |> Enum.each(fn item ->
        IO.puts("#{Color.yellow}Id: #{Color.cyan}#{item.id} #{Color.yellow}task:#{Color.cyan} #{item.task} #{Color.yellow}Status: #{Color.cyan}#{item.status}#{Color.white}")
      end)
      {:reply, :done, state}
    end
  end 
  
  # handle cast will help us change/modify the state
  @impl true
  def handle_cast({:setstatus, item}, state) when is_tuple(item) do
    {:ok, status, task_id} = item
    new_state = case status do 
      # if task is completed remove it!
      :completed -> %{
        tasks: state.tasks |> Enum.filter(fn item ->
          if item.id != task_id do item end
        end)
      }
      _ -> %{
        tasks: state.tasks |> Enum.map(fn item ->
          if (item.id == task_id), do: Map.replace(item, :status, status),
          else: item
        end)
      }
    end
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:addtask, item}, state) when is_map(item) do
    result = Map.put_new(item, :id, length(state.tasks)+1) 
    new_state = %{tasks: state.tasks ++ [result]}
    {:noreply, new_state}
  end
  
  @impl true
  def init(_state) do
    {:ok, %{tasks: []}}
  end
end
