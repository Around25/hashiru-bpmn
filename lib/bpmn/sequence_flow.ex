defmodule Bpmn.SequenceFlow do
  @moduledoc """
  Handle passing the token through a sequence flow element.

    iex> {:ok, context} = Bpmn.Engine.Context.start_link(%{"id" => "my_process"}, %{"username" => "test", "password" => "secret"})
    iex> Bpmn.SequenceFlow.execute({:bpmn_sequence_flow, {"from", "to"}}, %{"to" => {:bpmn_activity_task_script, {}}}, context)
    {:not_implemented}

    iex> {:ok, context} = Bpmn.Engine.Context.start_link(%{"id" => "my_process"}, %{"username" => "test", "password" => "secret"})
    iex> Bpmn.SequenceFlow.execute({:bpmn_sequence_flow, {"from", "to", {:bpmn_expression, {"elixir", "1!=1"}}}}, %{}, context)
    {:false}
  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  def tokenIn(elem, process, context), do: execute(elem, process, context)
  defp tokenOut({:bpmn_sequence_flow, {_, target}}, process, context), do: Bpmn.releaseToken(target, process, context)

  @doc """
  Execute the sequence flow logic
  """
  def execute({:bpmn_sequence_flow, {source, target, condition} }, process, context) do
    case Bpmn.Expression.execute(condition, context) do
      {:ok, true} -> execute({:bpmn_sequence_flow, {source, target}}, process, context)
      {:ok, false} -> {:false}
      _ -> {:error}
    end
  end
  def execute(elem, process, context), do: tokenOut(elem, process, context)

end