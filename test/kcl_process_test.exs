defmodule KCLProcessTest do
  use ExUnit.Case

  defmodule TestRecordProcessor do
    import RecordProcessor

    def process_records(records, input, output) do
      seq = records |> List.first |> Map.get "sequenceNumber"
      case checkpoint(input, output, seq) do
        :ok -> nil
        {:error, "ThrottlingException"} -> checkpoint(input, output, seq)
      end
    end

    def init_processor(arg, output), do: IO.puts "init processor"
    def shutdown("TERMINATE", input, output), do: checkpoint(input, output, nil)
    def shutdown(_, _, _), do: nil
  end

  test "It should respond to each action and output a status message" do
        input_specs = [
          %{:method => :init_processor, :action => "initialize", :input => ~s({"action":"initialize","shardId":"shard-000001"})},
          %{:method => :process_records, :action => "processRecords", :input => ~s({"action":"processRecords","records":[]})},
          %{:method => :shutdown, :action => "shutdown", :input => ~s({"action":"shutdown","reason":"TERMINATE"})},
        ]
        # pick any of the actions randomly to avoid writing a test for each
        :random.seed(:os.timestamp)
        input_spec = input_specs |> Enum.shuffle |> List.first
        processor = RecordProcessor
        {:ok, input} = StringIO.open(input_spec[:input])
        {:ok, output} = StringIO.open ""
        {:ok, error} = StringIO.open ""
        KCLProcess.run(processor, input, output, error)

        expected_output = ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        assert clean(content(output)) == clean(expected_output)
        assert content(error) == ""
        assert IO.read(input, 1) == :eof
  end

  test "It should process a normal stream of actions and produce expected output" do
    input_string = """
    {"action":"initialize","shardId":"shardId-123"}
    {"action":"processRecords","records":[{"data":"bWVvdw==","partitionKey":"cat","sequenceNumber":"456"}]}
    {"action":"checkpoint","checkpoint":"456","error":"ThrottlingException"}
    {"action":"checkpoint","checkpoint":"456"}
    {"action":"shutdown","reason":"TERMINATE"}
    {"action":"checkpoint","checkpoint":"456"}
    """

    # NOTE: The first checkpoint is expected to fail
    #       with a ThrottlingException and hence the
    #       retry.
    expected_output_string = """
    {"action":"status","responseFor":"initialize"}
    {"action":"checkpoint","checkpoint":"456"}
    {"action":"checkpoint","checkpoint":"456"}
    {"action":"status","responseFor":"processRecords"}
    {"action":"checkpoint","checkpoint":null}
    {"action":"status","responseFor":"shutdown"}
    """
    processor = TestRecordProcessor
    {:ok, input} = StringIO.open(input_string)
    {:ok, output} = StringIO.open ""
    {:ok, error} = StringIO.open ""
    KCLProcess.run(processor, input, output, error)

    # outputs should be same modulo some whitespaces
    assert clean(content(output)) == clean(expected_output_string)
    assert content(error) == ""
    assert IO.read(input, 1) == :eof
  end

  def clean string do
    String.replace string, ~r/\s+/, ""
  end

  def content stringio do
    {_, content} = StringIO.contents(stringio)
    content
  end
end
