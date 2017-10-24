defmodule Bpmn.Port.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      {Bpmn.Port.Nodejs, ["node ./priv/scripts/node.js"]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end