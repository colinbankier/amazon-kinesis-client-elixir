defmodule Kcl.ExecutorTest do
  use ExUnit.Case
  alias Kcl.Executor

  defmodule TestProcessor do

  end

  test "Call run with a module and config" do
    run = Executor.run TestProcessor, []
    assert run == :ok
  end
end
