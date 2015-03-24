defmodule Kcl.Executor do
  require Logger
  def run processor, config do
      [command, args] = ExecutorCommandBuilder.build(
        config_properties_path(config),
        system_properties,
        extra_class_path
      )
      Logger.info "execute command:\n#{command.join ' '}"

      System.cmd(command, args)
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

  end

  defp extra_class_path do

  end
end
