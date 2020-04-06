defmodule Kinext.ContextTest do
  use ExUnit.Case

  alias Kinext.Context

  test "init/0" do
    assert {:ok, %Context{ref: ref} = context} = Context.init()
    assert is_reference(ref)
    Context.shutdown(context)
  end
end
