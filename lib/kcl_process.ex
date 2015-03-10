defmodule KCLProcess do
  def initialize(processor_module, input \\ :stdin, output \\ :stdout, error \\ :stderr) do
    IOProxy.initialize({input, output, error})
    Agent.start_link(fn -> processor_module end, name: __MODULE__)
  end

  def run do
    IOProxy.read_line |> process_line
  end

  defp processor do
    Agent.get(__MODULE__, &(&1))
  end

  defp process_line(nil), do: nil
  defp process_line(line) do
    {:ok, action} = line |> JSX.decode
    case Map.get(action, "action") do
      "initialize" ->
        apply(processor, :init_processor, [Map.get(action, "shardId")])
      "processRecords" ->
        apply(processor, :process_records, [Map.get(action, "records")])
      "shutdown" ->
        apply(processor, :shutdown, [Map.get(action, "reason")])
      :else -> raise "Malformed Action"
    end
    %{"action" => action_value} = action
    IOProxy.write_action("status", %{responseFor: action_value})
    run
  end
end
