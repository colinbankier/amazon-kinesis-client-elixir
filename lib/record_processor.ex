defmodule RecordProcessor do
  def checkpoint input, output, seq do
    IO.puts(output, checkpoint_response(seq))
    {:ok, action} = IO.read(input, :line) |> JSX.decode
    IO.puts "checkpoint #{inspect action}"
    case action do
      %{"action" => "checkpoint", "error" => error} -> {:error, error}
      _ -> :ok
    end
  end

  defp checkpoint_response value do
    ~s({"action":"checkpoint","checkpoint":"#{value}"})
  end
end
