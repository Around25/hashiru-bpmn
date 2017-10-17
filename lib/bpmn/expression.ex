defmodule Bpmn.Expression do
  @moduledoc """
  Bpmn.Expression
  ===============

  Validate a Bpmn condition expression and return it's value.

    iex> {:ok, context} = Bpmn.Context.start_link(%{}, %{})
    iex> Bpmn.Expression.execute({:bpmn_expression, {"elixir", "1==2"}}, context)
    {:ok, false}

    iex> {:ok, context} = Bpmn.Context.start_link(%{}, %{})
    iex> Bpmn.Expression.execute({:bpmn_expression, {"elixir", "1<2"}}, context)
    {:ok, true}

    The following example illustrates how we can execute an Elixir expression on the data in our context:

    iex> {:ok, context} = Bpmn.Context.start_link(%{}, %{})
    iex> Bpmn.Context.put_data(context, "count", 4)
    iex> Bpmn.Expression.execute({:bpmn_expression, {"elixir", "data[\\"count\\"]==4"}}, context)
    {:ok, true}

  """

  @doc """
  Validate a Bpmn condition expression and return the result
  """
  def execute({:bpmn_expression, {_, ""}}, _), do: {:ok, true}
  def execute({:bpmn_expression, {lang, expr}}, context), do: {:ok, evaluate(lang, expr, context)}

  @doc """
    Evaluate an elixir expression within the given context
  """
  def evaluate("elixir", expr, context) do
    data = Bpmn.Context.get(context, :data)
    q = "f = fn (data) ->
    #{expr}
    end"
    { _, binding } = Code.eval_string q
    binding[:f].(data)
  end

end