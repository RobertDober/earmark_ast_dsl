defmodule EarmarkAstDsl.ParaTest do
  use ExUnit.Case

  import EarmarkAstDsl

  describe "para w/o atts" do
    test "empty" do
      actual = p()
      expect = {"p", [], [], %{}}

      assert actual == expect
    end

    test "one child -> []" do
      actual = p("hello")
      expect = {"p", [], ["hello"], %{}}

      assert actual == expect
    end

    test "still one child" do
      actual = p(~w[world])
      expect = {"p", [], ["world"], %{}}

      assert actual == expect
    end

    test "more children" do
      actual = p(~w[hello world])
      expect = {"p", [], ["hello", "world"], %{}}

      assert actual == expect
    end
  end

  describe "attributes" do
    test "empty" do
      actual = p(nil, %{a: 1})
      expect = {"p", [{"a", "1"}], [], %{}}

      assert actual == expect
    end

    test "much more" do
      actual = p("", %{a: 1, b: 2})
      expect = {"p", [{"a", "1"}, {"b", "2"}], [""], %{}}

      assert actual == expect
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
