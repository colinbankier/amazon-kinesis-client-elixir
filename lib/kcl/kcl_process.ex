defmodule Kcl.KCLProcess do
  alias Kcl.IOProxy

  @default_options [
    input: :stdio,
    output: :stdio,
    error: :stderr,
    sleep_seconds: 5,
    checkpoint_retries: 5,
    checkpoint_freq_seconds: 60
  ]

  def run(processor, options \\ @default_options) do
    options = Dict.merge(@default_options, options)
    options |> Dict.take([:input, :output, :error])
    |> IOProxy.initialize

    process processor
  end

  defp process processor do
    IOProxy.read_line |> process_line(processor)
  end

  defp process_line(nil, _), do: nil
  defp process_line(line, processor) do
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
    process processor
  end
end
