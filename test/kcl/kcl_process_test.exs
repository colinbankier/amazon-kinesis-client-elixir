defmodule Kcl.KCLProcessTest do
  use ExUnit.Case
  alias Kcl.KCLProcess
  alias Kcl.RecordProcessor
  alias Kcl.IOProxy
  import TestHelper

  defmodule DoNothingRecordProcessor do
    @moduledoc """
      Overrides default RecordProcessor functions to prevent checkpointing
      to allow testing of basic message handling.
    """
    use RecordProcessor

    def process_records(data), do: nil
    def shutdown(args), do: nil
  end

  test "It should respond to init_processor and output a status message" do
        input_spec = %{
          :method => :init_processor,
          :action => "initialize",
          :input => ~s({"action":"initialize","shardId":"shard-000001"})
        }
        io = open_io(input_spec[:input])

        KCLProcess.run(DoNothingRecordProcessor, io)

        ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        |> assert_io io
  end

  test "It should respond to process_shards and output a status message" do
        input_spec = %{
          :method => :process_records,
          :action => "processRecords",
          :input => ~s({"action":"processRecords","records":[]})
        }
        io = open_io(input_spec[:input])

        KCLProcess.run(DoNothingRecordProcessor, io)

        ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        |> assert_io io
  end

  test "It should respond to shutdown and output a status message" do
        input_spec = %{
          :method => :shutdown,
          :action => "shutdown",
          :input => ~s({"action":"shutdown","reason":"TERMINATE"})
        }
        io = open_io(input_spec[:input])

        KCLProcess.run(DoNothingRecordProcessor, io)

        ~s({"action":"status","responseFor":"#{input_spec[:action]}"})
        |> assert_io io
  end

  defmodule DefaultRecordProcessor do
    @moduledoc """
      Uses default checkpointing behaviour of RecordProcessor module.
    """
    use RecordProcessor

    def process_record data do

    end
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

    io = open_io input_string

    KCLProcess.run(DefaultRecordProcessor, io)

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
    assert_io expected_output_string, io
  end

  def assert_io expected_output, [input: input, output: output, error: error] do
    assert clean(content(output)) == clean(expected_output)
    assert content(error) == ""
    assert IO.read(input, 1) == :eof
  end

  def clean string do
    String.replace string, ~r/\s+/, ""
  end
end
