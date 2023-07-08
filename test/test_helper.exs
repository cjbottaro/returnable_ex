ExUnit.start()

defmodule TestHelper do

  defmacro macro(do: block) do
    quote do
      var!(x) = "foo"
      unquote(block)
    end
  end

end
