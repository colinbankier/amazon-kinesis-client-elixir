defmodule Kcl.ConfigurationTest do
  use ExUnit.Case

  @required_options [application_name: "MyApp", stream_name: "MyStream"]

  test "default properties" do
    config_options = @required_options
    properties = Kcl.Configuration.properties config_options
    default_properties = [
      "AWSCredentialsProvider=DefaultAWSCredentialsProviderChain",
      "initialPositionInStream=TRIM_HORIZON"
    ] |> Enum.join "\n"


    assert String.match? properties, ~r{executableName=elixir}
    assert String.match? properties, ~r{processingLanguage=elixir/#{System.version}}
    assert String.contains? properties, default_properties
  end

  test "converts atoms to property names" do
    config_options = [
      dummy_key: 1,
      dummy_key_two: 'two'
    ] |> Dict.merge(@required_options)

    properties = Kcl.Configuration.properties config_options

    assert String.contains? properties, "dummyKey=1\ndummyKeyTwo=two"
  end

  test "Can set AWSCredentialsProvider" do
    config_options = [
      aws_credentials_provider: 'Test'
    ] |> Dict.merge @required_options

    properties = Kcl.Configuration.properties config_options

    assert String.contains? properties, "AWSCredentialsProvider=Test"
  end

  test "Application name can be set from ENV var" do
    System.put_env "APP_NAME", "Test App"
    config_options = [stream_name: 'MyStream']

    properties = Kcl.Configuration.properties config_options

    assert String.contains? properties, "applicationName=Test App"
  end

  test "Errors when missing required property" do
    ~w(
    executable_name application_name processing_language
    aws_credentials_provider initial_position_in_stream stream_name
    )
    |> Enum.each fn key_prop ->
      config_options = Dict.merge(
      @required_options,
      [{String.to_atom(key_prop), nil}]
      )

      assert_raise RuntimeError, "#{key_prop} is required", fn ->
        Kcl.Configuration.properties config_options
      end
    end
  end
end
