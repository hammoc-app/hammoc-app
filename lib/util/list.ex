defmodule Util.List do
  @moduledoc "Collection of utility functions for `List`."

  @doc """
  Prepends elements to a list.

  Returns list if elements is nil.

  ## Examples

      iex> Util.List.prepend([1, 3, 2], [0, 5])
      [0, 5, 1, 3, 2]

      iex> Util.List.prepend([1, 3, 2], nil)
      [1, 3, 2]
  """
  def prepend(list, elements)

  def prepend(list, nil), do: list
  def prepend(list, elements), do: elements ++ list
end
