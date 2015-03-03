defmodule KCLProcess do
  def run(processor, input, output, error) do
    read(processor, input, output, error)
  end

  defp read(processor, input, output, error) do
    IO.read(input, :line) |> process_line(processor, input, output, error)
  end

  defp process_line(:eof, _processor, _input, _output, _error), do: nil
  defp process_line line, processor, input, output, error do
    {:ok, action} = line |> IO.inspect |> JSX.decode
    case Map.get(action, "action") do
      "initialize" ->
        dispatch(processor, :init_processor, Map.get(action, "shardId"))
      "processRecords" ->
        dispatch(processor, :process_records, Map.get(action, "records"))
      "shutdown" ->
        dispatch(processor, :shutdown, Map.get(action, "reason"))
      :else -> raise "Malformed Action"
    end
    IO.puts(output, response(action))
    read(processor, input, output, error)
  end

  defp dispatch(processor, function_name, arg) do
    apply(processor, function_name, [arg])
  end

  defp response action = %{"action" => action} do
    ~s({"action":"status","responseFor":"#{action["action"]}"})
  end
end
