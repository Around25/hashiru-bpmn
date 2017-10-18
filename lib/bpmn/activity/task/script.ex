defmodule Bpmn.Activity.Task.Script do
  @moduledoc """
  Handle passing the token through an event element.

    iex> Bpmn.Port.Nodejs.eval_string("1+1", %{cosmin: "soss"})
    %{"context" => %{"cosmin" => "soss"}, "script" => "1+1", "type" => "string"}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  def tokenIn(elem, context), do: execute(elem, context)

  defp tokenOut(elem, context), do: {:not_implemented}

  @doc """
  Execute the start event business logic
  """
  def execute({:bpmn_activity_task_script, %{outputs: outputs, type: type, script: script} }, context) do
    IO.inspect Bpmn.Port.Nodejs.eval_string("1+3", %{testing: "something"})
#    case Bpmn.Expression.execute(condition, context) do
#      {:ok, true} -> execute({:bpmn_sequence_flow, {source, target}}, context)
#      {:ok, false} -> {:false}
#      _ -> {:error}
#    end
  end
  def execute(elem, context), do: tokenOut(elem, context)

end