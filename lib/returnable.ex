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
    def return(value, id), do: throw {__MODULE__, value, id}
  end

  defmodule AST do
    @moduledoc false
    def transform(id, block) do
      {block, {0, 0}} = Macro.traverse(block, {0, 0},
        fn
          # Keep track of our nesting level. We only want to mess with things on
          # the first level of nesting (nest == 0) because recursive invocations
          # of the macro will take care of the rest.
          {:returnable, _meta, _args} = node, {nest, pipe} -> {node, {nest+1, pipe}}

          # Keep track of our piping level. If we're in a pipe, then we should
          # have one less arg in our return calls.
          {:|>, _meta, _args} = node, {0, pipe} -> {node, {0, pipe+1}}

          # Nesting level 0 and not in a pipe.
          {:return, meta, args}, {0, 0} ->
            args = case args do
              nil -> [nil, id] # Empty bare return
              [] -> [nil, id]  # Empty parens return()
              args -> args ++ [id]
            end
            {{:return, meta, args}, {0, 0}}

          # Nesting level 0 and in a pipe.
          {:return, meta, args}, {0, pipe} ->
            args = case args do
              nil -> [id] # Empty bare return
              [] -> [id]  # Empty parens return()
              args -> args ++ [id]
            end
            {{:return, meta, args}, {0, pipe}}

          # All other nodes.
          node, acc -> {node, acc}
        end,

        fn
          # Decrement our level of nesting.
          {:returnable, _meta, _args} = node, {nest, pipe} -> {node, {nest-1, pipe}}

          # Decrement our level of piping.
          {:|>, _meta, _args} = node, {0, pipe} -> {node, {0, pipe-1}}

          # All other nodes.
          node, acc -> {node, acc}
        end
      )

      block
    end

    def debug(block) do
      Macro.traverse(block, 0,
        fn
          {op, _meta, args} = node, acc ->
            IO.puts("+++ #{acc} #{inspect {op, args}}")
            if op == :|> do
              IO.puts "#####################"
              Enum.each(args, &IO.inspect/1)
              IO.puts "#####################"
            end
            {node, acc}

          node, acc -> IO.puts("+++ #{acc} #{inspect node}"); {node, acc}
        end,

        fn
          {op, _meta, args} = node, acc -> IO.puts("--- #{acc} #{inspect {op, args}}"); {node, acc}
          node, acc -> IO.puts("--- #{acc} #{inspect node}"); {node, acc}
        end
      )
    end
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
  defmacro returnable(args \\ nil, block)
  defmacro returnable(_args, do: block) do
    id = :crypto.strong_rand_bytes(8)
    |> Base.encode16()

    # allowed

    block = AST.transform(id, block)

    quote do
      try do
        import Returnable.Return
        unquote(block)
      catch
        {Returnable.Return, v, unquote(id)} -> v
      end
    end
  end

  defmacro foo(args, do: block) do
    IO.inspect(args)
    quote do
      unquote(block)
    end
  end

  def test do
    block = quote do
      return
      5
    end

    AST.transform(:FOO, block)

    # block = quote do
    #   "test" |> return()
    #   "foo"
    # end

    # # AST.debug(block)
    # AST.transform(:FOO, block)
  end

end
