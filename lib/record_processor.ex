defmodule RecordProcessor do
  def checkpoint output, seq do
    IO.puts(output, checkpoint_response(seq))
  end

  defp checkpoint_response value do
    ~s({"action":"checkpoint","checkpoint":"#{value}"})
  end
end
