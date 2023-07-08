defmodule ReturnableTest do
  use ExUnit.Case
  doctest Returnable
  import Returnable

  test "generally works" do
    v = returnable do
      return 2
      1
    end

    assert v == 2
  end

  test "works with natural returns" do
    early = false

    v = returnable do
      if early do
        return 1
      end
      2
    end

    assert v == 2

    v = returnable do
      5
    end

    assert v == 5
  end

  test "is nestable (early returns)" do
    early = true

    v = returnable do
      x = returnable do
        if early do
          return 1
        end
        2
      end
      if x == 1 do
        return 3
      end
      4
    end

    assert v == 3
  end

  test "is nestable (natural returns)" do
    early = false

    v = returnable do
      x = returnable do
        if early do
          return 1
        end
        2
      end
      if x == 1 do
        return 3
      end
      4
    end

    assert v == 4
  end

  test "is nestable (natural + early)" do
    early = false

    v = returnable do
      x = returnable do
        if early do
          return 1
        end
        2
      end
      if x == 2 do
        return 3
      end
      4
    end

    assert v == 3
  end

  test "is nestable (early + natural)" do
    early = true

    v = returnable do
      x = returnable do
        if early do
          return 1
        end
        2
      end
      if x == 2 do
        return 3
      end
      4
    end

    assert v == 4
  end

  test "works with bare return and parens return" do
    x = returnable do
      return
      5
    end

    assert x == nil

    x = returnable do
      return()
      5
    end

    assert x == nil

    x = returnable do
      return(1)
      5
    end

    assert x == 1
  end

  test "works with pipes (parens)" do
    x = returnable do
      "foo" |> return()
      "bar"
    end

    assert x == "foo"
  end

  test "works with pipes (bar)" do
    x = returnable do
      "foo" |> return
      "bar"
    end

    assert x == "foo"
  end

  test "works with deep pipes (parens)" do
    x = returnable do
      "foo"
      |> String.upcase()
      |> return()
      "bar"
    end

    assert x == "FOO"
  end

  test "works with deep pipes (bare)" do
    x = returnable do
      "foo"
      |> String.upcase()
      |> return
      "bar"
    end

    assert x == "FOO"
  end

  test "pipes and nesting" do
    x = returnable do
      returnable do
        "foo"
        |> return
        "bar"
      end
      |> return
      "baz"
    end

    assert x == "foo"
  end

  test "allowed vars" do
    x = "foo"
    v = returnable x do
      x
    end

    assert v == "foo"
  end

  test "multiple allowed vars" do
    word = "BAR"
    x = "foo"
    y = "bar"

    v = returnable [word, x, y] do
      case String.downcase(word) do
        ^x -> String.downcase(x) |> return
        ^y -> String.downcase(y) |> return
      end
    end

    assert v == "bar"
  end

  test "nested allowed vars" do
    x = "foo"
    y = "bar"
    z = "baz"

    v = returnable [x, y, z] do
      if x == y, do: return z
      returnable z do
        return z
        "foo"
      end
    end

    assert v == z
  end

end
