defmodule TodoCacheTest do
  use ExUnit.Case

  setup do
    {:ok, cache} = Todo.Cache.start()
    on_exit(fn ->
        GenServer.stop(cache)
    end)
    {:ok, todo_cache: cache}
  end

  test "server_process", context do
    cache = context[:todo_cache]
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
    clear_data("alice")
    clear_data("bob")
  end

  test "to-do operations", context do
    cache = context[:todo_cache]
    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries_by_date(alice, ~D[2018-12-19])
    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
    clear_data("alice")
  end

  test "persistence" do
    {:ok, cache} = Todo.Cache.start()

    john = Todo.Cache.server_process(cache, "john")
    Todo.Server.add_entry(john, %{date: ~D[2018-12-20], title: "Shopping"})
    assert 1 == length(Todo.Server.entries_by_date(john, ~D[2018-12-20]))
    GenServer.stop(cache)
    {:ok, cache} = Todo.Cache.start()
    entries =
      cache
      |> Todo.Cache.server_process("john")
      |> Todo.Server.entries_by_date(~D[2018-12-20])

    assert [%{date: ~D[2018-12-20], title: "Shopping"}] = entries
    clear_data("john")
  end

  defp clear_data(name) do
    File.rm("./persist/" <> name)
  end
end
