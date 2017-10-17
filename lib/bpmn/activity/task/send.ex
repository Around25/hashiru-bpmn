defmodule Bpmn.Activity.Task.Send do
  @moduledoc """
  Handle passing the token through an event element.
  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  def tokenIn(elem, context), do: execute(elem, context)
  defp tokenOut(elem, context), do: {:not_implemented}

  @doc """
  Execute the start event business logic
  """
  def execute(elem, context), do: tokenOut(elem, context)

end