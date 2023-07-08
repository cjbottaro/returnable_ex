# Returnable

Early returns for Elixir

## Quickstart

```elixir
import Returnable

early = true

value = returnable do
  if early do
    return 1
  end
  2
end

value == 1 # true
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `returnable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:returnable, "~> 1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/returnable>.

