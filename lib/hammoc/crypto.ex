defmodule Hammoc.Crypto do
  @moduledoc """
  Entry point for encryption used in Hammoc.
  """

  alias Plug.Crypto.KeyGenerator

  @doc "Derive a key for the given salt (any static string) using `Plug.Crypto.KeyGenerator`."
  def key_for(salt, opts \\ []) do
    iterations = Keyword.get(opts, :key_iterations, 1000)
    length = Keyword.get(opts, :key_length, 32)
    digest = Keyword.get(opts, :key_digest, :sha256)
    cache = Keyword.get(opts, :cache, Plug.Keys)

    key_opts = [iterations: iterations, length: length, digest: digest, cache: cache]

    secret_key_base()
    |> validate_secret_key_base()
    |> KeyGenerator.generate(salt, key_opts)
  end

  defp validate_secret_key_base(nil) do
    raise(
      ArgumentError,
      "Please set the secret_key_base, either in the config for " <>
        "HammocWeb.Endpoint, or via the environment variable SECRET_KEY_BASE."
    )
  end

  defp validate_secret_key_base(secret_key_base) when byte_size(secret_key_base) < 64,
    do: raise(ArgumentError, "secret_key_base must be at least 64 bytes")

  defp validate_secret_key_base(secret_key_base), do: secret_key_base

  defp secret_key_base() do
    System.get_env("SECRET_KEY_BASE") ||
      Application.get_env(:hammoc, HammocWeb.Endpoint)[:secret_key_base]
  end
end
