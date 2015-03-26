defmodule Kcl.RecordProcessor do
  alias Kcl.IOProxy
  defmacro __using__(_) do
    quote do
      def init_processor(args), do: Kcl.RecordProcessor.init_processor(args)
      def process_records(records), do: Kcl.RecordProcessor.process_records(records)
      def shutdown(args), do: Kcl.RecordProcessor.shutdown(args)
      defoverridable [init_processor: 1, process_records: 1, shutdown: 1]
    end
  end

  def process_records(records) do
    Enum.each records, &(handle_record(&1))
    seq = records |> List.first |> Map.get "sequenceNumber"
    case checkpoint(seq) do
      :ok -> nil
      {:error, _} -> checkpoint(seq)
    end
  end
  def handle_record record do
    Base.decode64!(record["data"])
    |> process_record
  end
  def process_record data do
    IO.inspect data
  end
  def init_processor(_), do: nil
  def shutdown("TERMINATE"), do: checkpoint(nil)

  def checkpoint seq do
    IOProxy.write_action("checkpoint", %{checkpoint: seq})
    line = IOProxy.read_line
    case JSX.decode(line) do
      {:ok, action} -> handle_action action
      {:error, error} -> {:error, error, line}
    end
  end

  def handle_action action do
    case action do
      %{"action" => "checkpoint", "error" => error} -> {:error, error}
      _ -> :ok
    end
  end
end
