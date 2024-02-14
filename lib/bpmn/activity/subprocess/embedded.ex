defmodule Bpmn.Activity.Subprocess.Embedded do
  @moduledoc """
  Handle passing the token through an event element.

    iex> Bpmn.Activity.Subprocess.Embedded.tokenIn(%{}, nil)
    {:not_implemented}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  def tokenIn(elem, context), do: execute(elem, context)
  defp tokenOut(_elem, _context), do: {:not_implemented}
  @doc """
  Execute the start event business logic
  """
  def execute(elem, context), do: tokenOut(elem, context)

end