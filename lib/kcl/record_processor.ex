defmodule Kcl.RecordProcessor do
  alias Kcl.IOProxy
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      def process_records(records) do
        Enum.each records, &(handle_record(&1))
        seq = records |> List.first |> Map.get "sequenceNumber"
        case checkpoint(seq) do
          :ok -> nil
          {:error, _} -> checkpoint(seq)
        end
      end
      def handle_record record do
        record["data"]
        |> Base.decode64!
        |> process_record
      end
      def process_record(data), do: data
      def init_processor(_), do: nil
      def shutdown("TERMINATE"), do: checkpoint(nil)
      defoverridable [init_processor: 1, process_records: 1, shutdown: 1, process_record: 1]
    end
  end


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
