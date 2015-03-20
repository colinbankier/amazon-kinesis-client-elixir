defmodule Kcl.ExecutorCommandBuilderTest do
  use ExUnit.Case
  @properties_file_path __DIR__

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
end
