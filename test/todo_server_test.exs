defmodule TodoServerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, todo_server} = Todo.Server.start()
    on_exit(fn -> GenServer.stop(todo_server) end)
    {:ok, todo_server: todo_server}
  end

  test "no_entries", context do
    assert([] == Todo.Server.entries(context[:todo_server]))
  end

  test "add_entry", context do
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-19], title: "Dentist"})
    entry = Todo.Server.entries_by_date(context[:todo_server], ~D[2020-12-19])
    assert(1 == length(entry))

    assert("Dentist" == Enum.at(entry, 0).title)
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

  test "update entry", context do
    Todo.Server.add_entry(context[:todo_server], %{date: ~D[2020-12-24], title: "Dentist"})
    title = Enum.at(Todo.Server.entries_by_date(context[:todo_server], ~D[2020-12-24]), 0).title
    assert(title == "Dentist")

    Todo.Server.update_entry(context[:todo_server], 1, &Map.put(&1, :title, "Shopping"))
    title = Enum.at(Todo.Server.entries_by_date(context[:todo_server], ~D[2020-12-24]), 0).title
    assert(title == "Shopping")
  end

end
