defmodule Util.Keyword do
  @moduledoc "Collection of helper methods for keyword lists, complementing the `Keyword` module."

  @doc "Convert given list to a map"
  def to_map(list) do
    Enum.into(list, %{})
  end
end
