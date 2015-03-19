defmodule Kcl.KCLProcessTest do
  use ExUnit.Case
  alias Kcl.KCLProcess
  alias Kcl.RecordProcessor
  alias Kcl.IOProxy
  import TestHelper

  test "It should respond to init_processor and output a status message" do
        input_spec = %{
          :method => :init_processor,
          :action => "initialize",
          :input => ~s({"action":"initialize","shardId":"shard-000001"})
        }
        {input, output, error} = open_io(input_spec[:input])

        KCLProcess.initialize(RecordProcessor, input, output, error)
        KCLProcess.run

        ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        |> assert_io input, output, error
  end

  test "It should respond to process_shards and output a status message" do
        input_spec = %{
          :method => :process_records,
          :action => "processRecords",
          :input => ~s({"action":"processRecords","records":[]})
        }
        {input, output, error} = open_io(input_spec[:input])

        KCLProcess.initialize(RecordProcessor, input, output, error)
        KCLProcess.run

        ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        |> assert_io input, output, error
  end

  test "It should respond to shutdown and output a status message" do
        input_spec = %{
          :method => :shutdown,
          :action => "shutdown",
          :input => ~s({"action":"shutdown","reason":"TERMINATE"})
        }
        {input, output, error} = open_io(input_spec[:input])

        KCLProcess.initialize(RecordProcessor, input, output, error)
        KCLProcess.run

        ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        |> assert_io input, output, error
  end

  defmodule TestRecordProcessor do
    import RecordProcessor

    def process_records(records) do
      seq = records |> List.first |> Map.get "sequenceNumber"
      case checkpoint(seq) do
        :ok -> nil
        {:error, "ThrottlingException"} -> checkpoint(seq)
      end
    end

    def init_processor(_), do: nil
    def shutdown("TERMINATE"), do: checkpoint(nil)
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

    {input, output, error} = open_io input_string

    KCLProcess.initialize(TestRecordProcessor, input, output, error)
    KCLProcess.run

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
    assert_io expected_output_string, input, output, error
  end

  def assert_io expected_output, input, output, error do
    assert clean(content(output)) == clean(expected_output)
    assert content(error) == ""
    assert IO.read(input, 1) == :eof
  end

  def clean string do
    String.replace string, ~r/\s+/, ""
  end
end