defmodule Bpmn.SequenceFlow do
  @moduledoc """
  Handle passing the token through a sequence flow element.

    iex> {:ok, context} = Bpmn.Context.start_link(%{"to" => {:bpmn_activity_task_script, {}}}, %{"username" => "test", "password" => "secret"})
    iex> Bpmn.SequenceFlow.execute({:bpmn_sequence_flow, {"from", "to"}}, context)
    {:not_implemented}

    iex> {:ok, context} = Bpmn.Context.start_link(%{"to" => {:bpmn_activity_task_script, {}}}, %{"username" => "test", "password" => "secret"})
    iex> Bpmn.SequenceFlow.execute({:bpmn_sequence_flow, {"from", "to", {:bpmn_expression, {"elixir", "1!=1"}}}}, context)
    {:false}
  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  def tokenIn(elem, context), do: execute(elem, context)
  defp tokenOut({:bpmn_sequence_flow, {_, target}}, context), do: Bpmn.releaseToken(target, context)

  @doc """
  Execute the sequence flow logic
  """
  def execute({:bpmn_sequence_flow, {source, target, condition} }, context) do
    case Bpmn.Expression.execute(condition, context) do
      {:ok, true} -> execute({:bpmn_sequence_flow, {source, target}}, context)
      {:ok, false} -> {:false}
      _ -> {:error}
    end
  end
  def execute(elem, context), do: tokenOut(elem, context)

end