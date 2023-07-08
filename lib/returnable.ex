defmodule Returnable do
  @moduledoc """
  Early returns for code blocks.

  This module kind of encapsulates the idea of using `throw` to implement early
  returns:

      try do
        IO.puts "here"
        throw {:return, 123}
        IO.puts "there"
      catch
        {:return, v} -> v
      end

  But it does so in a more convenient and robust manner:

      returnable do
        IO.puts "here"
        return 123
        IO.puts "there
      end

  See `returnable/1` for more info.
  """

  defmodule Return do
    @moduledoc false
    def return(sig, value), do: throw {__MODULE__, sig, value}
  end

  @doc """
  Create a returnable block of code.

      import Returnable

      n = returnable do
        IO.puts "here"
        return 123
        IO.puts "there"
      end

      123 = n

  Typically you would wrap function bodies.

      import Returnable

      def foo(n) do
        returnable do
          if n < 10 do
            return n
          end

          n * 2
        end
      end

      5 = foo(5)
      20 = foo(10)

  Note that `return` is an alias for `return nil` and works without parenthesis.

      returnable do
        if not valid?(user) do
          return
        end

        process(user)
      end

  You can nest returnable blocks.

      returnable do
        x = returnable do
          if not some_condition() do
            return
          end
          calc_value()
        end

        if x == nil do
          return
        end

        do_something(x)
      end

  """
  defmacro returnable(block)
  defmacro returnable(do: block) do
    sig = :crypto.strong_rand_bytes(8)
    |> Base.encode16()

    # This macro is nestable. We only want to alter return calls for the level
    # of nesting we're currently on. Recursive evaluations of the macro will
    # handle the return alterations further down.

    {block, _} = Macro.traverse(block, 0,
      fn
        {:returnable, _meta, _args} = node, acc -> {node, acc+1}
        {:return, meta, nil}, 0 -> {{:return, meta, [sig, nil]}, 0} # Bare return
        {:return, meta, []}, 0 -> {{:return, meta, [sig, nil]}, 0}  # Parens return()
        {:return, meta, args}, 0 -> {{:return, meta, [sig | args]}, 0}
        node, acc -> {node, acc}
      end,

      fn
        {:returnable, _meta, _args} = node, acc -> {node, acc-1}
        node, acc -> {node, acc}
      end
    )

    quote do
      try do
        import Returnable.Return
        unquote(block)
      catch
        {Returnable.Return, unquote(sig), v} -> v
      end
    end
  end

end
