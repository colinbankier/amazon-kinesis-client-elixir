defmodule KCLProcess do
  def run(processor, input, output, error) do
    read(processor, input, output, error)
  end

  defp read(processor, input, output, error) do
    IO.read(input, :line) |> process_line(processor, input, output, error)
  end

  defp process_line(:eof, _processor, _input, _output, _error), do: nil
  defp process_line line, processor, input, output, error do
    {:ok, action} = line |> JSX.decode
    case Map.get(action, "action") do
      "initialize" ->
        dispatch(processor, :init_processor, [Map.get(action, "shardId"), output])
      "processRecords" ->
        dispatch(processor, :process_records, [Map.get(action, "records"), input, output])
      "shutdown" ->
        dispatch(processor, :shutdown, [Map.get(action, "reason"), input, output])
      :else -> raise "Malformed Action"
    end
    IO.puts(output, response(action))
    read(processor, input, output, error)
  end

  defp dispatch(processor, function_name, args) do
    apply(processor, function_name, args)
  end

  defp response(action = %{"action" => action_value}) do
    ~s({"action":"status","responseFor":"#{action_value}"})
  end
end
