defmodule Bpmn.Engine.Diagram do
  @moduledoc """

  iex> diagram = Bpmn.Engine.Diagram.load(File.read!("./priv/bpmn/examples/hiring/hiring.bpmn2"))
  iex> is_map(diagram)
  true

  iex> %{"processes"=>processes} = Bpmn.Engine.Diagram.load(File.read!("./priv/bpmn/examples/user_login.bpmn"))
  iex> is_list(processes)
  true

  iex> %{"processes"=>processes} = Bpmn.Engine.Diagram.load(File.read!("./priv/bpmn/examples/elements.bpmn"))
  iex> Enum.map(processes, &IO.inspect/1)
  iex> is_list(processes)
  true

  """
  
  def load(diagram) do
    {:ok, bpmn, _} = :erlsom.simple_form(diagram, [nameFun: &format_tag/3])
    load_definition(bpmn)
  end

  defp format_tag(name, _namespace, []) do "#{name}" end
  defp format_tag(name, 'http://www.omg.org/spec/BPMN/20100524/MODEL', _prefix), do: "bpmn2:#{name}"
  defp format_tag(name, _namespace, prefix) do
    "#{prefix}:#{name}"
  end

  defp load_definition({_tag, attrs, elems}) do
    attrs = format_attributes(attrs)
    %{
      "id" => attrs["id"] |> to_string,
      "expressionLanguage" => attrs["expressionLanguage"] |> to_string,
      "typeLanguage" => attrs["typeLanguage"] |> to_string,
      "processes" => load_processes(elems),
      "itemDefinitions" => load_item_definitions(elems)
    }
  end


  defp format_attributes(attrs) do
    attrs |> Enum.reduce(%{}, fn({key, val}, acc) -> Map.put(acc, key, val |> to_string) end)
  end

  defp load_item_definitions(elems) do
    elems
      |> Enum.flat_map(fn elem ->
        case elem do
          {"bpmn2:itemDefinition", attrs, _} ->
            [{:bpmn_item_definition, format_attributes(attrs)}]
          _ -> []
        end
      end)
      |> Enum.reduce(%{}, fn ({:bpmn_item_definition, attrs} = elem, acc) ->
        Map.put(acc, attrs["id"], elem)
      end)
  end

  defp load_processes(elems) do
    elems |> Enum.flat_map(fn elem ->
      case elem do
        {"bpmn2:process", attrs, process} ->
          [load_process("bpmn2:process", attrs, process)]
        _ -> []
      end
    end)
  end

  defp load_process("bpmn2:process", attrs, elems) do
    {:bpmn_process, format_attributes(attrs), map_process_elements(elems)}
  end

  defp map_process_elements(elems) do
    elems
      |> Enum.flat_map(&preload_element/1)
      |> Enum.reduce(%{}, fn ({_, attrs} = elem, acc) ->
        Map.put(acc, attrs["id"], elem)
      end)
  end


  defp preload_element({type, attrs, elems}) do
    attrs = format_attributes(attrs)
    case load_element(type, attrs, elems) do
      nil -> []
      elem -> [elem]
    end
  end

  defp load_refs(type, elems) do
    elems |> Enum.flat_map(fn elem ->
      case elem do
        {^type, _, [hd]} -> hd |> to_string
        _ -> []
      end
    end)
  end

  defp load_elements(type, elems) do
    elems |> Enum.flat_map(&(flat_find(type, &1)))
  end

  defp load_first_element(type, elems) do
    elems
      |> Enum.flat_map(&(flat_find(type, &1)))
      |> Enum.at(0)
  end

  defp flat_find(type, {type, _, _} = elem), do: preload_element(elem)
  defp flat_find(_, _), do: []


  @doc """
  Load a sequence flow
  """
  defp load_element("bpmn2:sequenceFlow", attrs, elems), do: {:bpmn_sequence_flow, %{
    "id" => attrs["id"] |> to_string,
    "name" => attrs["name"] |> to_string,
    "sourceRef" => attrs["sourceRef"] |> to_string,
    "targetRef" => attrs["targetRef"] |> to_string,
    "conditionExpression" => load_first_element("bpmn2:conditionExpression", elems),
    "isImmediate" => attrs["isImmediate"],
  }}

  defp load_element("bpmn2:incoming", _, [id]), do: id |> to_string
  defp load_element("bpmn2:outgoing", _, [id]), do: id |> to_string
  defp load_element("bpmn2:sourceRef", _, [id]), do: id |> to_string
  defp load_element("bpmn2:targetRef", _, [id]), do: id |> to_string
  defp load_element("bpmn2:property", attrs, _), do: {:bpmn_property, attrs}
  defp load_element("bpmn2:dataInput", attrs, _), do: {:bpmn_data_input, attrs}
  defp load_element("bpmn2:dataOutput", attrs, _), do: {:bpmn_data_output, attrs}
  defp load_element("bpmn2:dataOutputRefs", _, [id]), do: id |> to_string
  defp load_element("bpmn2:dataInputRefs", _, [id]), do: id |> to_string
  defp load_element("bpmn2:inputSet", attrs, elems), do: {:bpmn_input_set, Map.merge(attrs, %{"dataInputRefs"=>load_elements("bpmn2:dataInputRefs", elems)})}
  defp load_element("bpmn2:outputSet", attrs, elems), do: {:bpmn_output_set, Map.merge(attrs, %{"dataOutputRefs"=>load_elements("bpmn2:dataOutputRefs", elems)})}
  defp load_element("bpmn2:dataInputAssociation", attrs, elems), do: {:bpmn_data_input_association, Map.merge(attrs, %{
    "dataInputRefs"=>load_elements("bpmn2:dataInputRefs", elems),
    "sourceRef" => load_first_element("bpmn2:sourceRef", elems),
    "targetRef" => load_first_element("bpmn2:targetRef", elems),
    "assignment" => load_elements("bpmn2:assignment", elems),
  })}
  defp load_element("bpmn2:dataOutputAssociation", attrs, elems), do: {:bpmn_output_set, Map.merge(attrs, %{"dataOutputRefs"=>load_elements("bpmn2:dataOutputRefs", elems)})}
  defp load_element("bpmn2:ioSpecification", attrs, elems), do: {:bpmn_io_specification, Map.merge(attrs, %{
    "dataInput" => load_elements("bpmn2:dataInput", elems),
    "dataOutput" => load_elements("bpmn2:dataOutput", elems),
    "inputSet" => load_elements("bpmn2:inputSet", elems),
    "outputSet" => load_elements("bpmn2:outputSet", elems),
  })}
  defp load_element("bpmn2:assignment", attrs, elems), do: {:bpmn_assignment, Map.merge(attrs, %{
    "from"=>load_first_element("bpmn2:from", elems),
    "to"=>load_first_element("bpmn2:to", elems)
  })}
  defp load_element("bpmn2:from", attrs, [content]), do: {:bpmn_from, Map.merge(attrs, %{"content"=> content |> to_string})}
  defp load_element("bpmn2:to", attrs, [content]), do: {:bpmn_to, Map.merge(attrs, %{"content"=> content |> to_string})}
  defp load_element("bpmn2:conditionExpression", attrs, [content]), do: {:bpmn_condition_expression, Map.merge(attrs, %{
    "expression"=> content |> to_string
  })}
  defp load_element("bpmn2:script", attrs, [content]), do: {:bpmn_script, Map.merge(attrs, %{"expression"=> content |> to_string})}

  # TODO START EVENT: Load data input/output information
  defp load_element("bpmn2:startEvent", attrs, elems), do: {:bpmn_start_event, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems),
    "conditionalEventDefinition" => load_first_element("bpmn2:conditionalEventDefinition", elems),
    "compensateEventDefinition" => load_first_element("bpmn2:compensateEventDefinition", elems),
    "escalationEventDefinition" => load_first_element("bpmn2:escalationEventDefinition", elems),
    "errorEventDefinition" => load_first_element("bpmn2:errorEventDefinition", elems),
    "messageEventDefinition" => load_first_element("bpmn2:messageEventDefinition", elems),
    "signalEventDefinition" => load_first_element("bpmn2:signalEventDefinition", elems),
    "terminateEventDefinition" => load_first_element("bpmn2:terminateEventDefinition", elems),
    "timerEventDefinition" => load_first_element("bpmn2:timerEventDefinition", elems),
  })}

  # TODO END EVENT: Load data input/output information
  defp load_element("bpmn2:endEvent", attrs, elems), do: {:bpmn_end_event, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems),
    "conditionalEventDefinition" => load_first_element("bpmn2:conditionalEventDefinition", elems),
    "compensateEventDefinition" => load_first_element("bpmn2:compensateEventDefinition", elems),
    "escalationEventDefinition" => load_first_element("bpmn2:escalationEventDefinition", elems),
    "errorEventDefinition" => load_first_element("bpmn2:errorEventDefinition", elems),
    "messageEventDefinition" => load_first_element("bpmn2:messageEventDefinition", elems),
    "signalEventDefinition" => load_first_element("bpmn2:signalEventDefinition", elems),
    "terminateEventDefinition" => load_first_element("bpmn2:terminateEventDefinition", elems),
    "timerEventDefinition" => load_first_element("bpmn2:timerEventDefinition", elems),
  })}

  defp load_element("bpmn2:intermediateThrowEvent", attrs, elems), do: {:bpmn_end_event, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems),
    "conditionalEventDefinition" => load_first_element("bpmn2:conditionalEventDefinition", elems),
    "compensateEventDefinition" => load_first_element("bpmn2:compensateEventDefinition", elems),
    "escalationEventDefinition" => load_first_element("bpmn2:escalationEventDefinition", elems),
    "errorEventDefinition" => load_first_element("bpmn2:errorEventDefinition", elems),
    "messageEventDefinition" => load_first_element("bpmn2:messageEventDefinition", elems),
    "signalEventDefinition" => load_first_element("bpmn2:signalEventDefinition", elems),
    "terminateEventDefinition" => load_first_element("bpmn2:terminateEventDefinition", elems),
    "timerEventDefinition" => load_first_element("bpmn2:timerEventDefinition", elems),
  })}

  defp load_element("bpmn2:intermediateCatchEvent", attrs, elems), do: {:bpmn_end_event, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems),
    "conditionalEventDefinition" => load_first_element("bpmn2:conditionalEventDefinition", elems),
    "compensateEventDefinition" => load_first_element("bpmn2:compensateEventDefinition", elems),
    "escalationEventDefinition" => load_first_element("bpmn2:escalationEventDefinition", elems),
    "errorEventDefinition" => load_first_element("bpmn2:errorEventDefinition", elems),
    "messageEventDefinition" => load_first_element("bpmn2:messageEventDefinition", elems),
    "signalEventDefinition" => load_first_element("bpmn2:signalEventDefinition", elems),
    "terminateEventDefinition" => load_first_element("bpmn2:terminateEventDefinition", elems),
    "timerEventDefinition" => load_first_element("bpmn2:timerEventDefinition", elems),
  })}

  defp load_element("bpmn2:exclusiveGateway", attrs, elems), do: {:bpmn_gateway_exclusive, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems)
  })}

  defp load_element("bpmn2:inclusiveGateway", attrs, elems), do: {:bpmn_gateway_inclusive, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems)
  })}

  defp load_element("bpmn2:parallelGateway", attrs, elems), do: {:bpmn_gateway_parallel, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems)
  })}

  defp load_element("bpmn2:complexGateway", attrs, elems), do: {:bpmn_gateway_complex, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems)
  })}

  defp load_element("bpmn2:eventGateway", attrs, elems), do: {:bpmn_gateway_event, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems)
  })}

  defp load_element("bpmn2:serviceTask", attrs, elems), do: {:bpmn_task_service, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems)
  })}

  defp load_element("bpmn2:userTask", attrs, elems), do: {:bpmn_task_user, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems),
    "ioSpecification"=>load_elements("bpmn2:ioSpecification", elems),
    "dataInputAssociation"=>load_elements("bpmn2:dataInputAssociation", elems),
    "dataOutputAssociation"=>load_elements("bpmn2:dataOutputAssociation", elems)
  })}

  defp load_element("bpmn2:scriptTask", attrs, elems), do: {:bpmn_task_script, Map.merge(attrs, %{
    "incoming"=>load_elements("bpmn2:incoming", elems),
    "outgoing"=>load_elements("bpmn2:outgoing", elems),
    "ioSpecification"=>load_elements("bpmn2:ioSpecification", elems),
    "dataInputAssociation"=>load_elements("bpmn2:dataInputAssociation", elems),
    "dataOutputAssociation"=>load_elements("bpmn2:dataOutputAssociation", elems),
    "script"=>load_first_element("bpmn2:script", elems),
  })}

  defp load_element("bpmn2:dataStoreReference", attrs, elems), do: {:bpmn_data_store_reference, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:task", attrs, elems), do: {:bpmn_task, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:conditionalEventDefinition", attrs, elems), do: {:bpmn_event_definition_conditional, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:compensateEventDefinition", attrs, elems), do: {:bpmn_event_definition_compensate, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:escalationEventDefinition", attrs, elems), do: {:bpmn_event_definition_escalation, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:errorEventDefinition", attrs, elems), do: {:bpmn_event_definition_error, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:messageEventDefinition", attrs, elems), do: {:bpmn_event_definition_error, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:signalEventDefinition", attrs, elems), do: {:bpmn_event_definition_signal, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:terminateEventDefinition", attrs, elems), do: {:bpmn_event_definition_terminate, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:timerEventDefinition", attrs, elems), do: {:bpmn_event_definition_timer, Map.merge(attrs, %{"_elems" => elems})}
  defp load_element("bpmn2:extensionElements", attrs, elems), do: {:bpmn_extension_elements, Map.merge(attrs, %{"_elems" => elems})}

  defp load_element(type, _attrs, _elems) do IO.inspect(type); nil end

end
