defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server) do
    GenServer.call(todo_server, {:entries})
  end

  def entries_by_date(todo_server, date) do
    GenServer.call(todo_server, {:entries_by_date, date})
  end

  def update_entry(todo_server, entry_id, updater_fun) do
    GenServer.cast(todo_server, {:update_entry, entry_id, updater_fun})
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
  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    new_state = Todo.List.update_entry(todo_list, entry_id, updater_fun)
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

  @impl GenServer
  def handle_call({:entries}, _, todo_list) do
    {
      :reply,
      Todo.List.entries(todo_list),
      todo_list
    }
  end
end
