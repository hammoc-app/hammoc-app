defmodule Weaver.Graph do
  use GenServer

  @timeout :timer.seconds(60)
  @call_timeout :timer.seconds(75)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def store_object(id, statements) do
    GenServer.call(__MODULE__, {:store_object, id, statements}, @call_timeout)
  end

  def store_object!(id, statements) do
    case store_object(id, statements) do
      {:ok, result} -> result
      {:error, e} -> raise e
    end
  end

  def store_properties([]), do: :ok

  def store_properties(statements) do
    GenServer.call(__MODULE__, {:store_properties, statements})
  end

  def store_properties!(statements) do
    case store_properties(statements) do
      :ok -> :ok
      {:error, e} -> raise e
    end
  end

  def count(id, relation) do
    GenServer.call(__MODULE__, {:count, id, relation}, @call_timeout)
  end

  def count!(id, relation) do
    case count(id, relation) do
      {:ok, result} -> result
      {:error, e} -> raise e
    end
  end

  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  def reset!() do
    case reset() do
      :ok -> :ok
      {:error, e} -> raise e
    end
  end

  @impl GenServer
  def init(_args) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:store_object, id, statements}, _from, uids) do
    if uid = uids[id] do
      statement =
        Enum.map(statements, fn statement ->
          String.replace(statement, "uid(v)", "<#{uid}>")
        end)
        |> Enum.join("\n")
        |> IO.inspect(label: "STORING")

      response =
        case Dlex.mutate(Dlex, statement, timeout: @timeout) do
          {:ok, _} ->
            IO.inspect(%{id => uid}, label: "STORED")
            {:ok, %{id => uid}}

          {:error, e} ->
            {:error, e}
        end

      {:reply, response, uids}
    else
      statement =
        Enum.map(statements, fn statement ->
          String.replace(statement, "uid(v)", "_:#{id}")
        end)
        |> Enum.join("\n")
        |> IO.inspect(label: "STORING")

      case Dlex.mutate(Dlex, statement, timeout: @timeout) do
        {:ok, new_uids} ->
          IO.inspect(new_uids, label: "STORED")
          {:reply, {:ok, new_uids}, Map.merge(uids, new_uids)}

        {:error, e} ->
          {:reply, {:error, e}, uids}
      end
    end
  end

  def handle_call({:count, id, relation}, _from, state) do
    query = ~s"""
    {
      countRelation(func: eq(id, #{inspect(id)})) {
        c : count(#{relation})
      }
    }
    """

    result =
      case Dlex.query(Dlex, query, %{}, timeout: @timeout) do
        {:ok, %{"countRelation" => [%{"c" => count}]}} -> {:ok, count}
        {:error, e} -> {:error, e}
      end

    {:reply, result, state}
  end

  def handle_call({:store_properties, statements}, _from, uids) do
    IO.inspect(statements, label: "STORING")

    result =
      with {:ok, _result} <- Dlex.mutate(Dlex, Enum.join(statements, "\n"), timeout: @timeout) do
        :ok
      end

    {:reply, result, uids}
  end

  def handle_call(:reset, _from, _uids) do
    result =
      with {:ok, _result} <- Dlex.alter(Dlex, %{drop_all: true}),
           {:ok, _result} <- Dlex.alter(Dlex, "id: string @index(hash,trigram) @upsert .") do
        :ok
      end

    {:reply, result, %{}}
  end
end
