defmodule SimpleKinesisClient do
  import Kcl.AdvancedRecordProcessor

  def process_record data do
    IO.inspect data
  end
end
 
config = [stream_name: 'test',
  application_name: 'ElixirKCLSample',
  max_records: 5,
  idle_time_between_reads_in_millis: 500]

Kcl.Executor.run SimpleKinesisClient, config
