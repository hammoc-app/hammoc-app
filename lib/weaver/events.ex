defmodule Weaver.Events do
  alias Weaver.{Resolvers, Tree}

  def handle(event) do
    do_handle(event)
  end

  def do_handle(events, state \\ nil)

  def do_handle(events, state) when is_list(events) do
    Enum.reduce(events, {[], state}, fn event, {results, state} ->
      {new_results, state} = do_handle(event, state)
      {results ++ new_results, state}
    end)
  end

  def do_handle(event = %Tree{ast: {:document, ops}}, state) do
    continue_with(event, ops, state)
  end

  def do_handle(
        event = %Tree{ast: {:op, _type, _name, _vars, [], fields, _schema_info}},
        state
      ) do
    continue_with(event, fields, state)
  end

  def do_handle(
        event = %Tree{ast: {:frag, :..., {:name, _, _type}, [], fields, _schema_info}},
        state
      ) do
    continue_with(event, fields, state)
  end

  def do_handle(
        event = %Tree{
          ast: {:field, {:name, _, "node"}, [{"id", %{value: id}}], _, fields, _, _schema_info}
        },
        state
      ) do
    id
    |> Resolvers.retrieve_by_id()
    |> store()
    |> continue_with(event, fields, state)
  end

  def do_handle(
        %Tree{
          ast: {:field, {:name, _, field}, [], [], [], :undefined, _schema_info},
          data: {parent_uid, parent_obj}
        },
        state
      ) do
    value =
      Resolvers.resolve_leaf(parent_obj, field)
      |> IO.inspect(label: field)

    store_properties([{parent_uid, %{field => value}}])

    {[], state}
  end

  def do_handle(
        event = %Tree{
          ast: {:field, {:name, _, field}, [], [], fields, :undefined, _schema_info},
          data: {parent_uid, parent_obj}
        },
        state
      ) do
    # with total_count = Resolvers.total_count(parent_obj, field),
    #      count = Weaver.Graph.count!(Resolvers.id_for(parent_obj), field),
    #      count == total_count do
    #       Weaver.Graph.stream(Resolvers.id_for(parent_obj), field)
    case Resolvers.resolve_node(parent_obj, field) do
      {:retrieve, ^parent_obj, opts} ->
        event = %{event | data: {parent_uid, parent_obj}, ast: {:retrieve, opts, fields, field}}
        {[event], state}

      obj ->
        stored_obj = store(obj, [{parent_uid, field}])
        continue_with(stored_obj, event, fields, state)
    end
  end

  def do_handle(
        event = %Tree{
          ast: {:retrieve, opts, fields, parent_field},
          data: {parent_uid, parent_obj}
        },
        _state
      ) do
    case Resolvers.retrieve(parent_obj, opts, event.cursor) do
      {:continue, objs, cursor} ->
        IO.inspect("next #{length(objs)} #{opts}", label: "RETRIEVED")
        state = %{event | cursor: cursor, count: event.count + length(objs)}

        stored_objs = store(objs, [{parent_uid, parent_field}])
        continue_with(stored_objs, event, fields, state)

      {:done, objs} ->
        IO.inspect("last #{length(objs)} #{opts}", label: "RETRIEVED")
        state = nil

        stored_objs = store(objs, [{parent_uid, parent_field}])
        continue_with(stored_objs, event, fields, state)
    end
  end

  def do_handle(event, _state) do
    raise "Undhandled event:\n\n#{inspect(Map.from_struct(event), pretty: true)}"
  end

  defp continue_with(event, subtree, state) do
    IO.inspect(event, label: "ORIGINAL")

    for elem <- subtree do
      %{event | ast: elem}
    end
    |> do_handle(state)
    |> IO.inspect(label: "RESULT none")
  end

  defp continue_with(stored_objs, event, subtree, state) when is_list(stored_objs) do
    IO.inspect(event, label: "ORIGINAL")

    for stored_obj <- stored_objs, elem <- subtree do
      %{event | data: stored_obj, ast: elem}
    end
    |> do_handle(state)
    |> IO.inspect(label: "RESULT objs")
  end

  defp continue_with(stored_obj, event, subtree, state) do
    event
    |> Map.put(:data, stored_obj)
    |> continue_with(subtree, state)
  end

  defp store(objs, relations \\ [])

  defp store([], _relations), do: []

  defp store(objs, relations) when is_list(objs) do
    Enum.map(objs, fn obj ->
      id = Resolvers.id_for(obj)

      relation_statements =
        Enum.map(relations, fn {from, relation} ->
          "<#{from}> <#{relation}> uid(v) ."
          # "<#{from}> <#{relation}> _:#{id} ."
        end)

      statements = [~s|uid(v) <id> "#{id}" .| | relation_statements]
      uids = Weaver.Graph.store_object!(id, statements)

      {uids[id], obj}
    end)
  end

  # defp store(objs, relations) when is_list(objs) do
  #   uids =
  #     objs
  #     |> Enum.flat_map(fn obj ->
  #       id = Resolvers.id_for(obj)

  #       relation_statements =
  #         Enum.map(relations, fn {from, relation} ->
  #           "<#{from}> <#{relation}> uid(v) ."
  #           # "<#{from}> <#{relation}> _:#{id} ."
  #         end)

  #       ~s"""
  #       upsert {
  #         query {
  #           v as var(func: eq(id, "#{id}"))
  #         }

  #         mutation {
  #           set {
  #             uid(v) <id> "#{id}" .
  #             #{Enum.join(relation_statements, "\n")}
  #           }
  #         }
  #       }
  #       """
  #       |> List.wrap()

  #       [
  #         {id, ~s|v as var(func: eq(id, "#{id}"))|, %{"uid(v)" => id},
  #          [~s|uid(v) <id> "#{id}" .| | relation_statements]}
  #       ]

  #       # [~s|_:#{id} <id> "#{id}" .| | relation_statements]
  #     end)
  #     |> do_store()
  #     |> IO.inspect(label: "UIDS")

  #   Enum.map(objs, fn obj ->
  #     id = Resolvers.id_for(obj)
  #     {uids[id], obj}
  #   end)
  # end

  defp store(obj, relations) do
    [stored_obj] = store([obj], relations)
    stored_obj
  end

  def store_properties([{parent_uid, props}]) do
    props
    |> Enum.flat_map(fn
      {"id", _value} -> []
      {field, value} -> ["<#{parent_uid}> <#{field}> #{property(value)} ."]
    end)
    |> Weaver.Graph.store_properties!()

    # |> do_store()
  end

  defp property(int) when is_integer(int) do
    ~s|"#{int}"^^<xs:int>|
  end

  defp property(other), do: inspect(other)

  # defp do_store(""), do: %{}

  # defp do_store([]) do
  #   %{}
  # end

  # defp do_store([{id, query, map, mutation} | statements]) do
  #   IO.inspect({id, query, map, mutation}, label: "STORING")
  #   # Dlex.mutate!(Dlex, %{query: query}, "set { #{Enum.join(mutation, "\n")} }", [])
  #   # Dlex.mutate!(Dlex, %{query: query}, mutation, [])
  #   Dlex.mutate!(Dlex, %{query: query}, map, [])
  #   |> IO.inspect(label: "STORED")
  #   |> Enum.into(%{}, fn {_var, uid} -> {id, uid} end)
  #   |> IO.inspect(label: "STORED2")
  #   |> Map.merge(do_store(statements))
  # end

  # defp do_store([statement | statements]) do
  #   IO.inspect(statement, label: "STORING")

  #   Dlex.mutate!(Dlex, statement)
  #   |> IO.inspect(label: "STORED")
  #   |> Map.merge(do_store(statements))
  # end

  # # defp do_store(statements) when is_list(statements) do
  # #   statements
  # #   |> Enum.join("\n")
  # #   |> do_store()
  # # end

  # defp do_store(statement) do
  #   # IO.inspect(statement, label: "STORE")
  #   IO.puts("STORE:\n#{statement}\n\n")

  #   # {:ok, uids} =
  #   # Dlex.transaction(Dlex, fn conn ->
  #   #   Dlex.mutate(conn, statement)
  #   # end)

  #   # uids

  #   # case Dlex.query(Dlex, statement) do
  #   #   {:ok, result} ->
  #   #     result
  #   #     |> IO.inspect(label: "STORED")
  #   #   {:error, e} ->
  #   #     IO.puts(e.reason.message)
  #   #     raise(e)
  #   # end

  #   Dlex.mutate!(Dlex, statement)
  #   |> IO.inspect(label: "STORED")
  # end
end
