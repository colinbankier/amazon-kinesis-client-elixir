defmodule SimpleKinesisClient do
  use Kcl.RecordProcessor

  def process_record data do
    IO.puts "I got #{data}"
  end
end

Kcl.KCLProcess.run SimpleKinesisClient
