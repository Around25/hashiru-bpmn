defmodule Bpmn.Engine.Diagram do
  @moduledoc """

  iex> diagram = Bpmn.Engine.Diagram.load(File.read!("./priv/bpmn/examples/hiring/hiring.bpmn2"))
  iex> is_map(diagram)
  true

  iex> diagram = Bpmn.Engine.Diagram.load(File.read!("./priv/bpmn/examples/user_login.bpmn"))
  iex> is_map(diagram)
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
    attrs |> Enum.reduce(%{}, fn({key, val}, acc) -> Map.put(acc, key, val) end)
  end

  defp load_item_definitions(elems) do
    elems |> Enum.flat_map(fn elem ->
      case elem do
        {"bpmn2:itemDefinition", attrs, _} -> [{:bpmn_item_definition, format_attributes(attrs)}]
        _ -> []
      end
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

  defp map_process_elements(elems), do: elems |> Enum.flat_map(&preload_element/1)

  defp preload_element({type, attrs, elems}) do
    attrs = format_attributes(attrs)
    case load_element(type, attrs, elems) do
      nil -> []
      elem -> [elem]
    end
  end

  defp load_element("bpmn2:startEvent", attrs, elems), do: {:bpmn_start_event, attrs, elems}
  defp load_element("bpmn2:sequenceFlow", attrs, _elems), do: {:bpmn_sequence_flow, %{
    "id" => attrs["id"] |> to_string,
    "sourceRef" => attrs["sourceRef"] |> to_string,
    "targetRef" => attrs["targetRef"] |> to_string,
    "conditionExpression" => attrs["conditionExpression"] |> to_string,
    "isImmediate" => attrs["isImmediate"],
  }}
  defp load_element(_type, _attrs, _elems), do: nil

end
