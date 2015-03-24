# amazon-kinesis-client-elixir
An Elixir interface for the Amazon Kinesis Client Library.


# Build
`mvn generate-sources`
`mix do deps.get,compile`
# Test
`mix test`

# Run
Put records into stream
`aws kinesis put-record --stream-name "test" --region us-east-1 --profile colinb-sandbox --data "My Record" --partition-key 1`

