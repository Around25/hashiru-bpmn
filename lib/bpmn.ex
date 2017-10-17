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

  The nodes can return one of the following sets of data:
  - {:ok, context} => The process has completed successfully and returned some data in the context
  - {:error, _message, %{field: "Error message"}} => Error in the execution of the process with message and fields
  - {:manual, _} => The process has reached an external manual activity
  - {:fatal, _} => Fatal error in the execution of the process
  - {:not_implemented} => Process reached an unimplemented section of the process-

  Events
  ------



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
        name: "END",
        incoming: ["SequenceFlow_1keu1zs"],
        definitions: [{:error_event_definition, %{}}]
      }
    }


  """

  @doc """
  Parse a string representation of a process into an executable process representation
  """
  def parse(_process) do
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
  def releaseToken(targets, context) when is_list(targets) do
    targets
      |> Task.async_stream(&(releaseToken(&1, context)))
      |> Enum.reduce({:ok, context}, &reduce_result/2)
  end
  def releaseToken(target, context) do
    process = Bpmn.Context.get(context, :process)
    next = next(target, process)
    case next do
      nil -> {:error, "Unable to find node '#{target}'"}
      _ -> execute(next, context)
    end
  end

  @doc """
  Execute a node in the process
  """
  def execute({:bpmn_event_start, _}            = elem, context), do: Bpmn.Event.Start.tokenIn(elem, context)
  def execute({:bpmn_event_end, _}              = elem, context), do: Bpmn.Event.End.tokenIn(elem, context)
  def execute({:bpmn_event_intermediate, _}     = elem, context), do: Bpmn.Event.Intermediate.tokenIn(elem, context)
  def execute({:bpmn_event_boundary, _}         = elem, context), do: Bpmn.Event.Boundary.tokenIn(elem, context)

  def execute({:bpmn_activity_task_user, _}     = elem, context), do: Bpmn.Activity.Task.User.tokenIn(elem, context)
  def execute({:bpmn_activity_task_script, _}   = elem, context), do: Bpmn.Activity.Task.Script.tokenIn(elem, context)
  def execute({:bpmn_activity_task_service, _}  = elem, context), do: Bpmn.Activity.Task.Service.tokenIn(elem, context)
  def execute({:bpmn_activity_task_manual, _}   = elem, context), do: Bpmn.Activity.Task.Manual.tokenIn(elem, context)
  def execute({:bpmn_activity_task_send, _}     = elem, context), do: Bpmn.Activity.Task.Send.tokenIn(elem, context)
  def execute({:bpmn_activity_task_receive, _}  = elem, context), do: Bpmn.Activity.Task.Receive.tokenIn(elem, context)

  def execute({:bpmn_activity_subprocess, _}    = elem, context), do: Bpmn.Activity.Subprocess.tokenIn(elem, context)
  def execute({:bpmn_activity_subprocess_embeded, _} = elem, context), do: Bpmn.Activity.Subprocess.Embedded.tokenIn(elem, context)

  def execute({:bpmn_gateway_exclusive, _}      = elem, context), do: Bpmn.Gateway.Exclusive.tokenIn(elem, context)
  def execute({:bpmn_gateway_exclusive_event, _} = elem, context), do: Bpmn.Gateway.Exclusive.Event.tokenIn(elem, context)
  def execute({:bpmn_gateway_parallel, _}       = elem, context), do: Bpmn.Gateway.Parallel.tokenIn(elem, context)
  def execute({:bpmn_gateway_inclusive, _}      = elem, context), do: Bpmn.Gateway.Inclusive.tokenIn(elem, context)
  def execute({:bpmn_gateway_complex, _}        = elem, context), do: Bpmn.Gateway.Complex.tokenIn(elem, context)
  def execute({:bpmn_sequence_flow, _}          = elem, context), do: Bpmn.SequenceFlow.tokenIn(elem, context)

  def execute(elem, _, _) do
    IO.inspect(elem)
    nil
  end

  defp reduce_result({:ok, {:ok, _} = result}, {:ok, _}), do: result
  defp reduce_result({:ok, {:error, _} = result}, {:ok, _}), do: result
  defp reduce_result({:ok, {:error, _}}, {:error, _} = acc), do: acc
  defp reduce_result({:ok, {:fatal, _} = result}, _), do: result
  defp reduce_result({:ok, {:not_implemented} = result}, _), do: result
  defp reduce_result({:ok, {:manual, _} = result}, {:ok, _}), do: result
  defp reduce_result({:ok, {:manual, _}}, acc), do: acc
end
