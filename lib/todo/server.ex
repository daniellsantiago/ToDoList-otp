defmodule Todo.Server do
  use GenServer
  @moduledoc """
  Module responsible create a GenServer that manipulates Todo.List module
  """
  def start(name) do
    GenServer.start(__MODULE__, name)
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

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fun}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)
    Todo.Database.store(name, new_list)
    {:noreply,{name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries_by_date, date}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries_by_date(todo_list, date),
      {name, todo_list}
    }
  end

  @impl GenServer
  def handle_call({:entries}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list),
      {name, todo_list}
    }
  end
end
