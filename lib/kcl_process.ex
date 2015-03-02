defmodule KCLProcess do
  def run(processor, input, output, error) do
    {:ok, input_map} = IO.read(input, :all) |> JSX.decode
    IO.write(output, ~s([{"action":"status","responseFor":"#{input_map["action"]}"}]))
  end
end
