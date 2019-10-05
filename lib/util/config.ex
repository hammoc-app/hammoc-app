defmodule Util.Config do
  @moduledoc """
  Helper functions for working with dynamic runtime configuration of libraries such as ecto and phoenix
  """

  defmodule Var do
    @moduledoc "Specifies how a config variable should be computed."

    use TypedStruct

    typedstruct do
      field(:name, String.t(), enforce: true)
      field(:transform, (String.t() -> any()), default: &Var.preserve/1)
    end

    def preserve(val), do: val
  end

  def merge_environment_variables(config, env_vars) do
    merge_environment_variables(config, env_vars, System.get_env())
  end

  @doc """
  Helper function to merge selected environment variables into an existing config.
  Designed to be used in `c:Ecto.Repo.init/2` or `c:Phoenix.Endpoint.init/2` callback functions.

  ## Examples

      iex> Util.Config.merge_environment_variables(
      ...>   [host: "localhost", port: 80],
      ...>   [port: "PORT", scheme: "SCHEME", prefix: "PREFIX"],
      ...>   %{"PORT" => "8080", "SCHEME" => "https://"}
      ...> )
      {:ok, port: "8080", scheme: "https://", host: "localhost"}

      iex> Util.Config.merge_environment_variables(
      ...>   [url: [host: "example.com", port: 80]],
      ...>   [http: [port: "PORT"], url: [host: "SITE_HOST", port: "SITE_PORT"]],
      ...>   %{"PORT" => "8080", "SITE_HOST" => "hammoc.app"}
      ...> )
      {:ok, url: [host: "hammoc.app", port: 80], http: [port: "8080"]}

      iex> Util.Config.merge_environment_variables(
      ...>   [http: [:inet4, port: "8080"]],
      ...>   [http: [port: "PORT"], url: [host: "SITE_HOST", port: "SITE_PORT"]],
      ...>   %{"PORT" => "8080", "SITE_HOST" => "hammoc.app", "SITE_PORT" => "80"}
      ...> )
      {:ok, url: [host: "hammoc.app", port: "80"], http: [:inet4, port: "8080"]}

      iex> Util.Config.merge_environment_variables(
      ...>   [ciphers: [default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: "secuRRRe"}]],
      ...>   [ciphers: [default: {[key: %Util.Config.Var{name: "HAMMOC_VAULT_KEY", transform: &Base.decode64!/1}]}]],
      ...>   %{"HAMMOC_VAULT_KEY" => Base.encode64("m04rs3cuRRR3")}
      ...> )
      {:ok, ciphers: [default: {Cloak.Ciphers.AES.GCM, key: "m04rs3cuRRR3", tag: "AES.GCM.V1"}]}
  """
  @spec merge_environment_variables(Keyword.t(), Keyword.t()) :: {:ok, Keyword.t()}
  def merge_environment_variables(config, to_merge, env) do
    {:ok, do_merge(config, to_merge, env)}
  end

  # end condition
  defp do_merge(config_list, [], _env) do
    config_list
  end

  # nested lists -> go into
  defp do_merge([config_list], [tail], env) when is_list(config_list) and is_list(tail) do
    [do_merge(config_list, tail, env)]
  end

  # An atom in the existing config -> leave it in & continue
  defp do_merge([merge_elem | config_list], tail, env) when is_atom(merge_elem) do
    [merge_elem | do_merge(config_list, tail, env)]
  end

  # Keyword pair with string value (env var name) -> lookup & replace, then continue
  defp do_merge(config_list, [{merge_key, merge_val} | tail], env) when is_binary(merge_val) do
    case env[merge_val] do
      nil -> do_merge(config_list, tail, env)
      "" -> do_merge(config_list, tail, env)
      val -> Keyword.put(do_merge(config_list, tail, env), merge_key, val)
    end
  end

  # Keyword pair with Util.Config.Var value -> lookup & replace, then continue
  defp do_merge(
         config_list,
         [{merge_key, %Util.Config.Var{name: name, transform: fun}} | tail],
         env
       ) do
    case env[name] do
      nil -> do_merge(config_list, tail, env)
      "" -> do_merge(config_list, tail, env)
      val -> Keyword.put(do_merge(config_list, tail, env), merge_key, fun.(val))
    end
  end

  # Keyword pair with list value (nested sub config) -> recurse into sub config & replace, then continue
  defp do_merge(config_list, [{merge_key, merge_val} | tail], env) when is_list(merge_val) do
    old_sub_config_list = Keyword.get(config_list, merge_key, [])
    new_sub_config_list = do_merge(old_sub_config_list, merge_val, env)
    new_config_list = Keyword.put(config_list, merge_key, new_sub_config_list)
    do_merge(new_config_list, tail, env)
  end

  # Nested tuple -> recurse into sub config & replace, then continue
  defp do_merge(config_list, [{merge_key, merge_val} | tail], env) when is_tuple(merge_val) do
    old_sub_config_list = Keyword.get(config_list, merge_key, {}) |> Tuple.to_list()
    new_sub_config_list = do_merge(old_sub_config_list, Tuple.to_list(merge_val), env)
    new_config_list = Keyword.put(config_list, merge_key, List.to_tuple(new_sub_config_list))
    do_merge(new_config_list, tail, env)
  end
end
