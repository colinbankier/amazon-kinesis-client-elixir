defmodule Kcl.ExecutorCommandBuilder do
  def build properties_file_path do
    [java, "-cp"]
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
end
