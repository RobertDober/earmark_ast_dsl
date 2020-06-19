defmodule EarmarkAstDsl.TagTest do
  use ExUnit.Case

  import EarmarkAstDsl

  describe "tag" do
    test "simplest possible case" do
      actual = tag("anything")
      expect = {"anything", [], [], %{}}

      assert actual == expect
    end

    test "simplest possible case, symbolically speaking" do
      actual = tag(:anything)
      expect = {"anything", [], [], %{}}

      assert actual == expect
    end

    test "complex (but without)" do
      actual = tag(:alpha, ~w[beta gamma], [{"lang", "gr"}, {"code", "utf8"}])
      expect = {"alpha", [{"lang", "gr"}, {"code", "utf8"}], ~w[beta gamma], %{}}

      assert actual == expect
    end
  end
end
