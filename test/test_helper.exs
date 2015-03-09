ExUnit.start()

defmodule TestHelper do
  def open_io input_content do
    {:ok, input} = StringIO.open(input_content)
    {:ok, output} = StringIO.open ""
    {:ok, error} = StringIO.open ""
    {input, output, error}
  end

  def content stringio do
    {_, content} = StringIO.contents(stringio)
    content
  end
end
