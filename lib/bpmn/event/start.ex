defmodule Bpmn.Event.Start do
  @moduledoc """
  Handle passing the token through an event element.
  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  def tokenIn(elem, process, context), do: execute(elem, process, context)
  defp tokenOut(elem, process, context), do: {:not_implemented}

  @doc """
  Execute the start event business logic
  """
  def execute(elem, process, context) do
  end

end