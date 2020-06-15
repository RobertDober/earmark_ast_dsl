defmodule EarmarkAstDsl.TableTest do
  use ExUnit.Case

  import EarmarkAstDsl

  describe "MVP" do
    test "empty table" do
      actual = table("one")

      expect =
        {"table", [],
         [
           {"tbody", [],
            [
              {"tr", [],
               [
                 {"td", [{"style", "text-align: left;"}], ["one"]}
               ]}
            ]}
         ]}

      assert actual == expect
    end

    test "2x2" do
      actual =
        1..2
        |> Enum.map(fn rnb -> 1..2 |> Enum.map(fn cnb -> "#{rnb}-#{cnb}" end) end)
        |> table()

      expect =
        {"table", [],
         [
           {"tbody", [],
            [
              {"tr", [],
               [
                 {"td", [{"style", "text-align: left;"}], ["1-1"]},
                 {"td", [{"style", "text-align: left;"}], ["1-2"]}
               ]},
              {"tr", [],
               [
                 {"td", [{"style", "text-align: left;"}], ["2-1"]},
                 {"td", [{"style", "text-align: left;"}], ["2-2"]}
               ]}
            ]}
         ]}

      assert actual == expect
    end

    test "with header" do
      actual =
        1..2
        |> Enum.map(fn rnb -> 1..2 |> Enum.map(fn cnb -> "#{rnb}-#{cnb}" end) end)
        |> table(head: ~w[alpha beta])

      expect =
        {"table", [],
         [
           {"thead", [],
            [
              {"tr", [],
               [
                 {"th", [{"style", "text-align: left;"}], ["alpha"]},
                 {"th", [{"style", "text-align: left;"}], ["beta"]}
               ]}
            ]},
           {"tbody", [],
            [
              {"tr", [],
               [
                 {"td", [{"style", "text-align: left;"}], ["1-1"]},
                 {"td", [{"style", "text-align: left;"}], ["1-2"]}
               ]},
              {"tr", [],
               [
                 {"td", [{"style", "text-align: left;"}], ["2-1"]},
                 {"td", [{"style", "text-align: left;"}], ["2-2"]}
               ]}
            ]}
         ]}

      assert actual == expect
    end

    test "with strings" do
      actual = table("data", head: "header")

      expect =
        {"table", [],
         [
           {"thead", [],
            [
              {"tr", [],
               [
                 {"th", [{"style", "text-align: left;"}], ["header"]}
               ]}
            ]},
           {"tbody", [],
            [
              {"tr", [],
               [
                 {"td", [{"style", "text-align: left;"}], ["data"]}
               ]}
            ]}
         ]}
    end
  end
end
