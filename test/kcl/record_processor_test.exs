defmodule Kcl.RecordProcessorTest do
  use ExUnit.Case
  use Timex
  import TestHelper
  alias Kcl.IOProxy

  defmodule MyProcessor do
    use Kcl.RecordProcessor

    def process_record(data), do: "I got #{data}"
  end

  setup do
    :ok
  end

  test "process_record is called in client module with decoded data" do
    IOProxy.initialize open_io
    records = [create_record("Hello world!"), create_record("foobar")]

    assert MyProcessor.process_records(records) == ["I got Hello world!", "I got foobar"]
  end

  def create_record data do
    %{"data" => Base.encode64(data), "sequenceNumber" => 1, "partitionKey" => 1}
  end

  test "default config is set on initialize" do
    assert MyProcessor.state[:sleep_seconds] == 5
    assert MyProcessor.state[:checkpoint_retries] == 5
    assert MyProcessor.state[:checkpoint_freq_seconds] == 60
  end

  test "can set config on initialize" do
    MyProcessor.initialize sleep_seconds: 10,
                            checkpoint_retries: 10,
                            checkpoint_freq_seconds: 10

    assert MyProcessor.state[:sleep_seconds] == 10
    assert MyProcessor.state[:checkpoint_retries] == 10
    assert MyProcessor.state[:checkpoint_freq_seconds] == 10
  end

  test "checkpointing is reset on init_processor" do
    MyProcessor.init_processor 1234

    assert MyProcessor.state[:largest_seq] == nil
    assert_in_delta MyProcessor.state[:last_checkpoint_time], Date.epoch(:secs), 1
  end

  test "forces checkpoint with largest_seq on error" do
    io = open_io
    IOProxy.initialize io
    defmodule BrokenProcessor do
      use Kcl.RecordProcessor
        
      def process_record data do
        raise "oops"
      end
    end

    records = [create_record("Break me")]
    BrokenProcessor.initialize [largest_seq: 1234]
    BrokenProcessor.process_records records

    assert content(io[:output]) == "{\"action\":\"checkpoint\",\"checkpoint\":1234}\n"
  end

end
