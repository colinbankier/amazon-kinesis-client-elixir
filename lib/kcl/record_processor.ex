defmodule Kcl.RecordProcessor do
  alias Kcl.IOProxy
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @default_options [
        sleep_seconds: 5,
        checkpoint_retries: 5,
        checkpoint_freq_seconds: 60
      ]

      def initialize, do: initialize []
      def initialize(options) do
        Dict.merge(@default_options, options)
        |> ensure_started
      end

      def ensure_started, do: ensure_started(@default_options)
      def ensure_started options do
        alive? = Process.registered
        |> Enum.member?(__MODULE__)

        if !alive? do
          Agent.start_link(fn -> options end, name: __MODULE__)
        end
      end

      def state do
        ensure_started
        Agent.get(__MODULE__, &(&1))
      end

      def update fun do
        ensure_started
        Agent.update(__MODULE__, fun)
      end

      def process_records(records) do
        result = Enum.map records, &(handle_record(&1))
        seq = records |> List.first |> Map.get "sequenceNumber"
        case checkpoint(seq) do
          :ok -> nil
          {:error, _, _} -> checkpoint(seq)
        end

        result
      end

      def handle_record record do
        record["data"]
        |> Base.decode64!
        |> process_record
      end

      def init_processor(_) do
        update fn state ->
          state
          |> Dict.put(:largest_seq, nil)
          |> Dict.put(:last_checkpoint_time, Timex.Date.epoch(:secs))
        end
      end

      def process_record(data), do: data
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
