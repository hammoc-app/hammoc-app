defmodule Hammoc.Search do
  @moduledoc "Search functionality."

  alias __MODULE__.Facets

  @callback index(list()) :: :ok | {:error, any()}
  @callback total_count() :: {:ok, integer()} | {:error, any()}
  @callback clear() :: :ok | {:error, any()}
  @callback query(Facets.t()) :: {:ok, list(any())} | {:error, any()}
  @callback top_hashtags(Facets.t()) :: {:ok, list(String.t())} | {:error, any()}
  @callback top_profiles(Facets.t()) :: {:ok, list(map())} | {:error, any()}
  @callback autocomplete(String.t() | nil) :: {:ok, list(String.t())} | {:error, any()}
end
