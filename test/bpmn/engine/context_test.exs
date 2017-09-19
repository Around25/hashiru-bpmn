defmodule Bpmn.Engine.ContextTest do
  use ExUnit.Case, async: true
  alias Bpmn.Engine.Context

  doctest Bpmn.Engine.Context

  setup do
    {:ok, context} = Context.start_link(%{id: "my_process"}, %{"username": "test", "password": "secret"})
    {:ok, context: context}
  end

  test "create context", %{context: context} do
    assert Context.get(context, :process)[:id] == "my_process"

    Context.put_data(context, "milk", 3)
    assert Context.get_data(context, "milk") == 3

    Context.put_meta(context, "start_node", %{active: true, completed: false})
    assert Context.get_meta(context, "start_node").active == true
    assert Context.get_meta(context, "start_node").completed == false

    assert Context.is_node_active(context, "start_node") == true
    assert Context.is_node_completed(context, "start_node") == false
  end
end
