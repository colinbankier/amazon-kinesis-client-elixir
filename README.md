# amazon-kinesis-client-elixir
An Elixir interface for the Amazon Kinesis Client Library.


# Build
`mvn generate-sources`
`mix do deps.get,compile`
# Test
`mix test`

# Run
Set your AWS credientials:
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx

Run sample client:
`mix run sample/simple_kinesis_client.exs`

Put records into stream
`aws kinesis put-record --stream-name "test" --region us-east-1 --profile colinb-sandbox --data "My Record" --partition-key 1`

# License
The source code in this project, not including 3rd party JAR files, is licensed under the Apache License V2.

[LICENSE-2.0.txt](./LICENSE-2.0.txt)
