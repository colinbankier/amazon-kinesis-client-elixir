defmodule IOProxy do
  def initialize io_streams = {_input, _output, _error} do
    Agent.start_link(fn -> io_streams end, name: __MODULE__)
  end

  def read_line do
    {input, _, _} = current_state
    do_read input
  end

  def write_error(message) do
    {_, error, _} = current_state
    IO.puts error, error_string(message)
  end

  defp error_string(message) when is_binary(message), do: message
  defp error_string(message), do: inspect message

  defp current_state do
    Agent.get(__MODULE__, &(&1))
  end

  defp do_read input do
    line = IO.read(input, :line)
    case stripped = strip(line) do
      ""   -> do_read input
      :eof -> nil
      _    -> stripped
    end
  end

  defp strip(line) when is_binary(line) do
    String.replace line, ~r/\W|\n/, ""
  end
  defp strip(line), do: line
end
