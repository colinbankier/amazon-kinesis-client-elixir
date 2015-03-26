defmodule Kcl.ExecutorCommandBuilderTest do
  use ExUnit.Case
  @properties_file_path Path.join(__DIR__, "test.properties")

  test "java command with env variable set" do
    System.put_env "PATH_TO_JAVA", "my_java"
    command = Kcl.ExecutorCommandBuilder.build @properties_file_path

    assert hd(command) == "my_java"
  end

  test "java command without env variable set" do
    System.delete_env "PATH_TO_JAVA"
    java = System.find_executable "java"
    command = Kcl.ExecutorCommandBuilder.build @properties_file_path

    assert hd(command) == java
  end

  test "error if missing java path" do
    original_path = System.get_env "PATH"
    System.put_env "PATH", ""
    System.delete_env "PATH_TO_JAVA"
    command = Kcl.ExecutorCommandBuilder.build @properties_file_path

    assert hd(command) == {:error, "Missing JAVA PATH"}
    System.put_env "PATH", original_path
  end

  test "command -cp flag" do
    command = Kcl.ExecutorCommandBuilder.build @properties_file_path

    assert command |> Enum.at(1) == "-cp"
  end

  test "command classpath" do
    classpath = Kcl.ExecutorCommandBuilder.build(@properties_file_path)
    |> Enum.at(2)

    assert String.match? classpath, ~r{\A/(.+\.jar\:)+.+\z}
    assert String.contains? classpath, Path.dirname(@properties_file_path)
  end

  test "command client_class" do
    client_class = Kcl.ExecutorCommandBuilder.build(@properties_file_path)
    |> Enum.at(3)

    assert client_class == "com.amazonaws.services.kinesis.multilang.MultiLangDaemon"
  end

  test "command basename" do
    basename = Kcl.ExecutorCommandBuilder.build(@properties_file_path)
    |> Enum.at(4)

    assert basename == Path.basename(@properties_file_path)
  end

  test "with system properties" do
    system_properties = %{"log4j.configuration" => "log4j.properties", option2: "test"}

    command = Kcl.ExecutorCommandBuilder.build(@properties_file_path, system_properties)

    assert Enum.find(command, &(&1 == "-Dlog4j.configuration=log4j.properties"))
    assert Enum.find(command, &(&1 == "-Doption2=test"))
  end

  test "with extra_class_path" do
    classpath = Kcl.ExecutorCommandBuilder.build(@properties_file_path, [], ["test.jar"])
    |> Enum.at(2)

    assert String.contains? classpath, "test.jar"
  end
end
