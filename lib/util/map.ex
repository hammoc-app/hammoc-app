defmodule Util.Map do
  @moduledoc "Utility functions to augment `Map`."

  def subset?(map1, map2) do
    keys = Map.keys(map1)
    map2
    |> Map.take(keys)
    |> Map.equal?(map1)
  end
end