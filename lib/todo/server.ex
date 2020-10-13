defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries_by_date(todo_server, date) do
    GenServer.call(todo_server, {:entries_by_date, date})
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries_by_date, date}, _, todo_list) do
    {
      :reply,
      Todo.List.entries_by_date(todo_list, date),
      todo_list
    }
  end

    {
      :reply,
      Todo.List.entries(todo_list, date),
      todo_list
    }
  end
end
