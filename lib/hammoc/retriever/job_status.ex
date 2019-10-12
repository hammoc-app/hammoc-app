defmodule Hammoc.Retriever.Status do
  @moduledoc "Data structure for info about ongoing retrieval jobs."

  @type t :: %__MODULE__{
          jobs: list(__MODULE__.Job.t())
        }

  defstruct jobs: []

  defmodule Job do
    @moduledoc "Retrieval info for one particular retrieval job."

    @type t :: %__MODULE__{
            channel: String.t(),
            current: integer(),
            max: integer()
          }

    defstruct [:channel, :current, :max]
  end
end
