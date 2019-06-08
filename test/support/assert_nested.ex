defmodule Test.Support.AssertNested do
  @moduledoc false

  @doc "Test whether the former data structure is a nested subset of the latter."
  defmacro assert_nested(left, right) do
    quote do
      assert unquote(left) ==
               Test.Support.AssertNested.nested_subset(unquote(left), unquote(right))
    end
  end

  @doc """
  Extracts nested data from `right` that has the same structure as `left`.

  ## Examples

      iex> left = %{user: %{name: "Alex", teams: ["Clowns"]}}
      ...> right = %{user: %{name: "Annie", city: "Merida"}}
      ...> Test.Support.AssertNested.nested_subset(left, right)
      %{user: %{name: "Annie", teams: nil}}

      iex> left = %{user: %{name: "Alex", teams: ["Clowns"]}}
      ...> right = %{user: %{name: "Annie", city: "Merida", teams: ["Crocodiles"]}}
      ...> Test.Support.AssertNested.nested_subset(left, right)
      %{user: %{name: "Annie", teams: ["Crocodiles"]}}

      iex> left = {:ok, %{user: %{name: "Alex", teams: ["Clowns"]}}}
      ...> right = {:ok, %{user: %{name: "Annie", city: "Merida", teams: ["Crocodiles"]}}}
      ...> Test.Support.AssertNested.nested_subset(left, right)
      {:ok, %{user: %{name: "Annie", teams: ["Crocodiles"]}}}
  """
  def nested_subset(left = %type{}, right = %type{}) do
    right_fields = nested_subset(Map.from_struct(left), right)
    struct!(type, right_fields)
  end

  def nested_subset(%_type{}, right) do
    right
  end

  def nested_subset(left, right) when is_map(left) and is_map(right) do
    Enum.reduce(left, %{}, fn {key, left_val}, acc ->
      right_val = Map.get(right, key)

      Map.put(acc, key, nested_subset(left_val, right_val))
    end)
  end

  def nested_subset([left | left_tail], [right | right_tail]) do
    [nested_subset(left, right) | nested_subset(left_tail, right_tail)]
  end

  def nested_subset(left, right) when is_tuple(left) and is_tuple(right) do
    nested_subset(Tuple.to_list(left), Tuple.to_list(right))
    |> List.to_tuple()
  end

  def nested_subset(_left, right), do: right
end
