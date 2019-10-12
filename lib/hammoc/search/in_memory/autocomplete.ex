defmodule Hammoc.Search.InMemory.Autocomplete do
  @moduledoc "Provides basic auto-complete."

  def for(enum, mapper, query, limit \\ 5) do
    add_autocomplete_from(query, enum, mapper, limit, [], MapSet.new())
    |> MapSet.to_list()
  end

  defp add_autocomplete_from(_query, [], _mapper, _limit, [], results), do: results

  defp add_autocomplete_from(query, [tweet | tweets], mapper, limit, [], results) do
    words =
      ~r/[\w\-\_]+/i
      |> Regex.scan(String.downcase(mapper.(tweet)))
      |> List.flatten()

    add_autocomplete_from(query, tweets, mapper, limit, words, results)
  end

  defp add_autocomplete_from(query, tweets, mapper, limit, [word | words], results) do
    if String.starts_with?(word, query) do
      if MapSet.member?(results, word) do
        add_autocomplete_from(query, tweets, mapper, limit, words, results)
      else
        new_results = MapSet.put(results, word)

        if MapSet.size(new_results) == limit do
          new_results
        else
          add_autocomplete_from(query, tweets, mapper, limit, words, new_results)
        end
      end
    else
      add_autocomplete_from(query, tweets, mapper, limit, words, results)
    end
  end
end
