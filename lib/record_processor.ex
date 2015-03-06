defmodule RecordProcessor do
  def init_processor(_, _), do: nil

  def process_records(_, _), do: nil
  def process_records(_, _, _), do: nil

  def shutdown(_, _, _), do: nil
  defoverridable [process_records: 3]
  defoverridable [process_records: 2]
  defoverridable [shutdown: 3]

  def checkpoint input, output, seq do
    IO.puts(output, checkpoint_response(seq))
    line = IO.read(input, :line)
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

  defp checkpoint_response value do
    {:ok, json} = JSX.encode %{action: "checkpoint", checkpoint: value}
    json
  end
end
