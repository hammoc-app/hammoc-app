defmodule Weaver.Supervisor do
  use Supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Weaver.GenStage.Producer,
      processor(:weaver_processor_1a, [Weaver.GenStage.Producer]),
      processor(:weaver_processor_2a, [:weaver_processor_1a]),
      processor(:weaver_processor_3a, [:weaver_processor_2a]),
      processor(:weaver_processor_4a, [:weaver_processor_3a]),
      processor(:weaver_processor_5a, [:weaver_processor_4a]),
      processor(:weaver_processor_6a, [:weaver_processor_5a]),
      processor(:weaver_processor_7a, [:weaver_processor_6a]),
      processor(:weaver_processor_8a, [:weaver_processor_7a]),
      processor(:weaver_processor_9a, [:weaver_processor_8a], :consumer)
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp processor(name, subscriptions, role \\ :producer_consumer)

  defp processor(name, subscriptions, :consumer) do
    Supervisor.child_spec(
      {Weaver.GenStage.Consumer, {name, subscriptions}},
      id: name
    )
  end

  defp processor(name, subscriptions, :producer_consumer) do
    Supervisor.child_spec(
      {Weaver.GenStage.Prosumer, {name, subscriptions}},
      id: name
    )
  end
end
