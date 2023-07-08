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

he package can be installed by adding `returnable` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:returnable, "~> 1.0"}
  ]
end
```

## Documentation

The docs can be found at <https://hexdocs.pm/returnable>.
