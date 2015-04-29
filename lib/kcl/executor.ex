defmodule Kcl.Executor do
  require Logger
  use GenServer

  def start_link options do
    GenServer.start(__MODULE__, options)
  end

  def run options do
    start_link options
  end

  def init options do
    pid = execute(options)
    Logger.info "Executor spawned #{inspect pid}"
    {:ok, pid}
  end

  def execute config do
      [command | args] = Kcl.ExecutorCommandBuilder.build(
        config_properties_path(config),
        system_properties,
        extra_class_path
      )
      Logger.info "execute command:\n#{command} #{Enum.join args, " "}"

      # Porcelain.spawn(command, args)
      Porcelain.spawn_shell "while 1; do sleep 1; echo looping; done"
  end

  def terminate(reason, proc) do
    Logger.info "Executor terminating: #{inspect reason}"
    # Porcelain.Process.stop proc
  end

  defp config_properties_path config do
    properties = Kcl.Configuration.properties config
    path = Radpath.mktempfile
    File.write(path, properties)
    Logger.info "properties path: #{path}"
    Logger.info "properties:\n#{File.read! path}"

    path
  end

  defp system_properties do
    []
  end

  defp extra_class_path do
    []
  end
end
