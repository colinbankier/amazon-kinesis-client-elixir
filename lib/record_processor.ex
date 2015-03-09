defmodule RecordProcessor do
  def init_processor(_), do: nil
  def process_records(_, _, _), do: nil
  def shutdown(_, _, _), do: nil

  defoverridable [
    init_processor: 1,
    process_records: 3,
    shutdown: 3
  ]

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
