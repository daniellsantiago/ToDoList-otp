defmodule TodoServerTest do
  use ExUnit.Case, async: true
  @server_name "server_test"

  setup do
    clear_data()
    {:ok, database_pid} = Todo.Database.start()
    {:ok, todo_server} = Todo.Server.start(@server_name)
    on_exit(fn ->
        clear_data()
        GenServer.stop(todo_server)
        GenServer.stop(database_pid)
        clear_data()
    end)
    {:ok, todo_server: todo_server}
  end

  test "no_entries", context do
    entries = Todo.Server.entries(context[:todo_server])
    assert([] == entries)
  end

  test "find_all_entries", context do
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-19], title: "Dentist"})
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-20], title: "School"})
    entries = Todo.Server.entries(context[:todo_server])
    assert(2 == length(entries))
    assert("Dentist" == Enum.at(entries, 0).title)
    assert("School" == Enum.at(entries, 1).title)
    assert([%{date: ~D[2020-12-19], id: 1, title: "Dentist"}, %{date: ~D[2020-12-20], id: 2, title: "School"}] == entries)
  end

  test "add_entry", context do
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-19], title: "Dentist"})
    entry = Todo.Server.entries_by_date(context[:todo_server], ~D[2020-12-19])
    assert(1 == length(entry))
    assert("Dentist" == Enum.at(entry, 0).title)
  end

  test "update entry", context do
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-24], title: "Dentist"})
    title = Enum.at(Todo.Server.entries_by_date(context[:todo_server], ~D[2020-12-24]), 0).title
    assert(title == "Dentist")

    Todo.Server.update_entry(context[:todo_server], 1, &Map.put(&1, :title, "Shopping"))
    title = Enum.at(Todo.Server.entries_by_date(context[:todo_server], ~D[2020-12-24]), 0).title
    assert(title == "Shopping")
  end

  test "delete entry", context do
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-24], title: "Dentist"})
    assert(1 == length Todo.Server.entries(context[:todo_server]))
    Todo.Server.delete_entry(context[:todo_server], 1)
    assert([] == Todo.Server.entries(context[:todo_server]))
  end

  defp clear_data do
    File.rm("./persist/" <> @server_name)
  end
end
