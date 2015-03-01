defmodule KCLProcessTest do
  use ExUnit.Case

  test "It should respond to each action and output a status message" do
        input_specs = [
          %{:method => :init_processor, :action => "initialize", :input => ~s({"action":"initialize","shardId":"shard-000001"})},
          %{:method => :process_records, :action => "processRecords", :input => ~s({"action":"processRecords","records":[]})},
          %{:method => :shutdown, :action => "shutdown", :input => ~s("action":"shutdown","reason":"TERMINATE"})},
        ]
        # pick any of the actions randomly to avoid writing a test for each
        input_spec = input_specs |> Enum.shuffle |> List.first
        processor = KCLEx.RecordProcessor
        {:ok, input} = StringIO.open(input_spec[:input])
        {:ok, output} = StringIO.open ""
        {:ok, error} = StringIO.open ""
        KCLProcess.run(processor, input, output, error)

        expected_output = ~s([{"action":"status","responseFor":"#{input_spec[:action]}"}])
        assert String.replace(IO.read(output, :all), ~r/\s+/, "") == String.replace(expected_output, ~r/\s+/, "")
        assert IO.read(error, :all) == ""
        assert IO.read(input, 1) == :eof
  end
end
