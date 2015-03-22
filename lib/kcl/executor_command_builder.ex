defmodule Kcl.ExecutorCommandBuilder do
  def build properties_file_path, system_properties \\ [], extra_class_path \\ [] do
    [
      java,
      system_property_options(system_properties),
      "-cp",
      classpath(properties_file_path, extra_class_path),
      client_class,
      Path.basename(properties_file_path)
    ] |> List.flatten
  end

  defp java do
    command = System.get_env("PATH_TO_JAVA") ||
    System.find_executable("java")

    cond do
      command == nil or command == "" ->
        {:error, "Missing JAVA PATH"}
      :else -> command
    end
  end

  defp system_property_options system_properties do
    Enum.map system_properties, fn {key, value} ->
      "-D#{key}=#{value}"
    end
  end

  defp classpath properties_file_path, extra_class_path do
    File.ls!(jar_dir)
    |> Enum.filter(&(String.ends_with?(&1, ".jar")))
    |> Enum.concat(extra_class_path)
    |> Enum.concat(properties_file_dir(properties_file_path))
    |> Enum.join(":")
  end

  defp extra_class_path do end

  defp properties_file_dir(properties_file_path) do
    case File.dir?(properties_file_path) do
      true  -> properties_file_path
      false -> Path.dirname(properties_file_path)
    end
    |> List.wrap
  end

  defp client_class do
    "com.amazonaws.services.kinesis.multilang.MultiLangDaemon"
  end

  defp jar_dir do
    Path.expand "../jars", __DIR__
  end
end
