defmodule Kcl.RecordProcessorTest do
  use ExUnit.Case

  test "process_record is called in client module with decoded data" do
    defmodule MyProcessor do
      use Kcl.RecordProcessor

      def process_record(data), do: "I got #{data}"
    end

    message = "Hello world!"
    record = %{"data" => Base.encode64(message), "sequenceNumber" => 1, "partitionKey" => 1}

    assert MyProcessor.handle_record(record) == "I got Hello world!"
  end
end
