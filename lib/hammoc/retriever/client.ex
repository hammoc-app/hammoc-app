defmodule Hammoc.Retriever.Client do
  @moduledoc "Defines callbacks for a Twitter client module."

  alias Hammoc.Retriever.Status.Job

  @callback init() :: {:ok, Job.t()} | {:error, any()}
  @callback next_batch(Job.t()) :: {:ok, list(any()), Job.t()} | {:error, any()}
end
