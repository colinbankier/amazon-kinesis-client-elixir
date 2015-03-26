
config = [stream_name: "test",
  executable_name: "./sample/simple_kinesis_processor.sh",
  application_name: "ElixirKCLSample",
  max_records: 5,
  idle_time_between_reads_in_millis: 500]

Kcl.Executor.run config
