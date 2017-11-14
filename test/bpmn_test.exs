defmodule BpmnTest do
  use ExUnit.Case
  doctest Bpmn
  doctest Bpmn.Activity.Subprocess
  doctest Bpmn.Activity.Subprocess.Embedded
  doctest Bpmn.Activity.Task.Manual
  doctest Bpmn.Activity.Task.Receive
  doctest Bpmn.Activity.Task.Send
  doctest Bpmn.Activity.Task.Service
  doctest Bpmn.Activity.Task.User
  doctest Bpmn.Event.Boundary
  doctest Bpmn.Event.End
  doctest Bpmn.Event.Intermediate
  doctest Bpmn.Gateway.Exclusive.Event
  doctest Bpmn.Gateway.Complex
  doctest Bpmn.Gateway.Exclusive
  doctest Bpmn.Gateway.Inclusive
  doctest Bpmn.Gateway.Parallel
end
