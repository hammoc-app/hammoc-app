defmodule Hammoc.Search.Facets do
  @moduledoc "Data structure and helpers to deal with the filters form."

  @type t :: %__MODULE__{
          hashtags: list(String.t()) | nil,
          profiles: list(String.t()) | nil,
          query: String.t() | nil,
          page: integer()
        }

  defstruct [:hashtags, :profiles, :query, page: 1]

  @doc """
  Transforms facets into URL params to generate a (URL) path.

  ## Examples

      iex> %Hammoc.Search.Facets{hashtags: ["elixirlang", "liveview"], query: "dev"}
      ...> |> Hammoc.Search.Facets.to_url_params()
      %{"hashtags" => "elixirlang,liveview", "q" => "dev"}
  """
  def to_url_params(facets = %__MODULE__{}) do
    %{}
    |> add_url_list_param("hashtags", facets.hashtags)
    |> add_url_list_param("profiles", facets.profiles)
    |> add_url_param("q", facets.query)
    |> add_url_param("p", facets.page, 1)
  end

  defp add_url_list_param(params, _key, nil), do: params

  defp add_url_list_param(params, key, val) when is_list(val) do
    Map.put(params, key, Enum.join(val, ","))
  end

  defp add_url_list_param(params, _key, _val), do: params

  defp add_url_param(params, key, val, default \\ nil)
  defp add_url_param(params, _key, default, default), do: params

  defp add_url_param(params, key, val, _default) do
    Map.put(params, key, val)
  end

  @doc """
  Transforms form params so they can be given as (URL) path options.

  ## Examples

      iex> %{"hashtags" => %{"elixirlang" => "true"}, "q" => "testing"}
      ...> |> Hammoc.Search.Facets.from_params()
      %Hammoc.Search.Facets{hashtags: ["elixirlang"], query: "testing"}

      iex> %{"hashtags" => %{"elixirlang" => "true", "liveview" => "true"}, "q" => ""}
      ...> |> Hammoc.Search.Facets.from_params()
      %Hammoc.Search.Facets{hashtags: ["elixirlang", "liveview"]}

      iex> %{"hashtags" => "elixirlang", "q" => "testing"}
      ...> |> Hammoc.Search.Facets.from_params()
      %Hammoc.Search.Facets{hashtags: ["elixirlang"], query: "testing"}

      iex> %{"hashtags" => "elixirlang,liveview", "q" => ""}
      ...> |> Hammoc.Search.Facets.from_params()
      %Hammoc.Search.Facets{hashtags: ["elixirlang", "liveview"]}

      iex> %{"hashtags" => "elixirlang,liveview", "p" => "3"}
      ...> |> Hammoc.Search.Facets.from_params()
      %Hammoc.Search.Facets{hashtags: ["elixirlang", "liveview"], page: 3}
  """
  def from_params(params) do
    %__MODULE__{
      hashtags: from_list_param(params["hashtags"]),
      profiles: from_list_param(params["profiles"]),
      query: from_text_param(params["q"]),
      page: from_number_param(params["p"], 1)
    }
  end

  defp from_list_param(nil), do: nil
  defp from_list_param(""), do: nil

  defp from_list_param(str) when is_binary(str) do
    String.split(str, ",")
  end

  defp from_list_param(map) when is_map(map) do
    for {item, "true"} <- map, do: item
  end

  defp from_text_param(nil), do: nil
  defp from_text_param(""), do: nil
  defp from_text_param(str) when is_binary(str), do: str

  defp from_number_param(nil, default), do: default
  defp from_number_param("", default), do: default
  defp from_number_param(str, _default), do: String.to_integer(str)

  @doc """
  List filtering with support for a mapper function.
  Criteria can be an inclusion list, or a String that the (mapped)
  value should be included in.
  """
  def filter_by(list, nil, _mapper), do: list

  def filter_by(list, criteria, mapper) do
    Enum.filter(list, fn elem ->
      elem
      |> mapper.()
      |> include_result?(criteria)
    end)
  end

  defp include_result?(values, inclusion_list)
       when is_list(values) and is_list(inclusion_list) do
    Enum.any?(values, &(&1 in inclusion_list))
  end

  defp include_result?(value, inclusion_list) when is_list(inclusion_list) do
    value in inclusion_list
  end

  defp include_result?(value, query) when is_binary(query) do
    String.match?(value, ~r/#{query}/iu)
  end
end
