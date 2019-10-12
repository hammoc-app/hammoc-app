defmodule Util.Map do
  @moduledoc "Collection of utility functions for Map."

  @doc """
  Transforms keys of a (nested) map to atoms.

  Use this only for a fixed set of keys to be expected!

  ## Examples

      iex> %{"users" => [%{"name" => "Cathy"}]}
      ...> |> Util.Map.deep_atomize_keys()
      %{users: [%{name: "Cathy"}]}
  """
  def deep_atomize_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), deep_atomize_keys(v)}
      {k, v} -> {k, deep_atomize_keys(v)}
    end)
  end

  def deep_atomize_keys(list) when is_list(list) do
    Enum.map(list, &deep_atomize_keys/1)
  end

  def deep_atomize_keys(other), do: other
end
