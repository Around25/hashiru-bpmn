defmodule Bpmn.Event.Start do
  @moduledoc """
  Handle passing the token through an event element.

  # Start Event

  A BPMN start event can have the following BPMN contents:

      <bpmn:startEvent id="StartEvent_1" name="START" camunda:initiator="HTTP">
        <bpmn:outgoing>SequenceFlow_0u2ggjm</bpmn:outgoing>

        <bpmn:extensionElements>
          <camunda:formData>
            <camunda:formField id="username" label="Username" type="string">
              <camunda:validation>
                <camunda:constraint name="username" config="required" />
                <camunda:constraint name="password" config="required" />
              </camunda:validation>
            </camunda:formField>
            <camunda:formField id="password" label="Password" type="string" />
          </camunda:formData>
          <camunda:executionListener class="bpmn.event.start.listener" event="start" />
        </bpmn:extensionElements>
      </bpmn:startEvent>

  This node can be represented as the following Elixir token:

      {:bpmn_event_start,
        %{
          id: "StartEvent_1",
          name: "START",
          outgoing: ["SequenceFlow_0u2ggjm"],
          inputs: [%{"username"=>"user", "password"=>"password"}],
          definitions: [{:error_event_definition, %{}}]
        }
      }

  ## Examples

    iex> {:ok, context} = Bpmn.Context.start_link(%{}, %{})
    iex> {:ok, pid} = Bpmn.Event.Start.tokenIn({:bpmn_event_start, %{outgoing: []}}, context)
    iex> context == pid
    true

    iex> {:ok, context} = Bpmn.Context.start_link(%{"to" => {:bpmn_activity_task_script, {}}}, %{})
    iex> {:not_implemented} = Bpmn.Event.Start.tokenIn({:bpmn_event_start, %{outgoing: ["to"]}}, context)
    iex> true
    true

#    iex> {:ok, context} = Bpmn.Context.start_link(%{"to" => {:bpmn_activity_task_script, {}}}, %{"username" => "test", "password" => "secret"})
#    iex> {:ok, pid} = Bpmn.Event.Start.tokenIn({:bpmn_event_start, %{outgoing: ["to"]}}, context)
#    iex> context == pid
#    true
  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed

  @todo:
    - Load input data into the context based on the given inputs
    - Check the event definitions and wait for the event to be triggered before executing the event

  """
  def tokenIn({:bpmn_event_start, %{outgoing: []}}, context), do: {:ok, context}
  def tokenIn(elem, context), do: execute(elem, context)

  @doc """
  Execute the start event business logic
  """
  def execute({:bpmn_event_start, %{outgoing: outgoing} = _event}, context) do
    tokenOut(outgoing, context)
  end

  defp tokenOut(targets, context), do: Bpmn.releaseToken(targets, context)

end