defmodule Bpmn.Port.Nodejs do
  use GenServer

  def start_link cmd \\ nil do
    cmd = case cmd do
      nil-> ["node /Users/cosmin/Incubator/github/hashiru/bpmn/priv/scripts/node.js"]
      _-> cmd
    end
    GenServer.start_link __MODULE__, cmd, name: __MODULE__
  end

  def eval_script script, context do
    GenServer.call __MODULE__, {:script, script, context}
  end

  def eval_string script, context do
    GenServer.call __MODULE__, {:string, script, context}
  end

  def close do
    GenServer.call __MODULE__, {:close}
  end

  ## callbacks

  def init cmd do
    port = Port.open {:spawn, hd(cmd)}, [:binary]
    {:ok, port}
  end

  def handle_call({:string, script, context}, from, port), do: send_request({"string", script, context}, from, port)
  def handle_call({:script, script, context}, from, port), do: send_request({"file", script, context}, from, port)

  def handle_call {:close}, _, port do
    Port.close port
    {:reply, :ok, nil}
  end

  def handle_call _, _from, nil do
    {:stop, :port_closed, nil}
  end

  defp send_request {type, script, context}, _, port do
    msg = Poison.encode!(%{
      type: type,
      script: script,
      context: context,
    })
    result = case Port.command port, msg do
      true -> receive do
                {^port, {:data, result}} ->
                  {:ok, result}

              after 5_000 -> {:error, :timed_out}
              end

      false -> {:error, :process_dead}
    end

    case result do
      {:error, reason} -> {:stop, reason, nil}
      {:ok, x} -> {:reply, Poison.decode!(x), port}
    end
  end
end