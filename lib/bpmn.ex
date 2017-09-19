defmodule Bpmn do
  @moduledoc """
  BPMN Execution Engine
  =====================

  Hashiru BPMN allows you to execute any BPMN process in Elixir.

  Each node in the BPMN process can be mapped to the appropriate Elixir token and added to a process.
  Each loaded process will be added to a Registry under the id of that process.
  From there they can be loaded by any node and executed by the system.

  Node definitions
  ================

  Each node can be represented in Elixir as a token in the following format: {:bpmn_node_type, :any_data_type}

  Events
  ------

  ### Start Event

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
          inputs: []
        }
      }

  ### End Event

  BPMN definition:

      <bpmn:endEvent id="EndEvent_1s3wrav">
        <bpmn:incoming>SequenceFlow_1keu1zs</bpmn:incoming>
        <bpmn:errorEventDefinition />
      </bpmn:endEvent>

  Elixir token:

    {:bpmn_event_end,
      %{
        id: "EndEvent_1s3wrav",
        name: "START",
        incoming: ["SequenceFlow_1keu1zs"],
        definitions: {:error_event_definition, %{}}
      }
    }


  """

  @doc """
  Parse a string representation of a process into an executable process representation
  """
  def parse(process) do
    {:ok, %{"start_node_id" => {:bpmn_event_start, %{}}}}
  end

  @doc """
  Get a node from a process by target id
  """
  def next(target, process) do
    Map.get(process, target)
  end

  @doc """
  Release token to another target node
  """
  def releaseToken(target, process, context) do
    next = next(target, process)
    case next do
      nil -> {:error, "Unable to find node '#{target}'"}
      _ -> execute(next, process, context)
    end
  end

  @doc """
  Execute a node in the process
  """
  def execute(elem, process, context) do
    case elem do
      # Events
      {:bpmn_event_start, _}              -> Bpmn.Event.Start.tokenIn(elem, process, context)
      {:bpmn_event_end, _}                -> Bpmn.Event.End.tokenIn(elem, process, context)
      {:bpmn_event_intermediate, _}       -> Bpmn.Event.Intermediate.tokenIn(elem, process, context)
      {:bpmn_event_boundary, _}           -> Bpmn.Event.Boundary.tokenIn(elem, process, context)

      # Activities
      {:bpmn_activity_task_user, _}       -> Bpmn.Activity.Task.User.tokenIn(elem, process, context)
      {:bpmn_activity_task_script, _}     -> Bpmn.Activity.Task.Script.tokenIn(elem, process, context)
      {:bpmn_activity_task_service, _}    -> Bpmn.Activity.Task.Service.tokenIn(elem, process, context)
      {:bpmn_activity_task_manual, _}     -> Bpmn.Activity.Task.Manual.tokenIn(elem, process, context)
      {:bpmn_activity_task_send, _}       -> Bpmn.Activity.Task.Send.tokenIn(elem, process, context)
      {:bpmn_activity_task_receive, _}    -> Bpmn.Activity.Task.Receive.tokenIn(elem, process, context)

      # Subprocess
      {:bpmn_activity_subprocess, _}          -> Bpmn.Activity.Subprocess.tokenIn(elem, process, context)
      {:bpmn_activity_subprocess_embeded, _}  -> Bpmn.Activity.Subprocess.Embedded.tokenIn(elem, process, context)

      # Gateways
      {:bpmn_gateway_exclusive, _}        -> Bpmn.Gateway.Exclusive.tokenIn(elem, process, context)
      {:bpmn_gateway_exclusive_event, _}  -> Bpmn.Gateway.Exclusive.Event.tokenIn(elem, process, context)
      {:bpmn_gateway_parallel, _}         -> Bpmn.Gateway.Parallel.tokenIn(elem, process, context)
      {:bpmn_gateway_inclusive, _}        -> Bpmn.Gateway.Inclusive.tokenIn(elem, process, context)
      {:bpmn_gateway_complex, _}          -> Bpmn.Gateway.Complex.tokenIn(elem, process, context)

      # Other elements
      {:bpmn_sequence_flow, _}            -> Bpmn.SequenceFlow.tokenIn(elem, process, context)
      _ ->
        IO.inspect elem
        nil
    end
  end
end
