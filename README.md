# EarmarkAstDsl

[![Build Status](https://travis-ci.org/robertdober/earmark_ast_dsl.svg?branch=master)](https://travis-ci.org/robertdober/earmark_ast_dsl)
[![Hex.pm](https://img.shields.io/hexpm/v/earmark_ast_dsl.svg)](https://hex.pm/packages/earmark_ast_dsl)
[![Hex.pm](https://img.shields.io/hexpm/dw/earmark_ast_dsl.svg)](https://hex.pm/packages/earmark_ast_dsl)
[![Hex.pm](https://img.shields.io/hexpm/dt/earmark_ast_dsl.svg)](https://hex.pm/packages/earmark_ast_dsl)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `earmark_ast_dsl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:earmark_ast_dsl, "~> 0.2.1"}
  ]
end
```

## API

EarmarkAstDsl is a toolset to generate EarmarkParser conformant AST Nodes version 1.4.6 and on,
which is the _always return quadruples_ version.

Its main purpose is to remove boilerplate code from Earmark and
EarmarkParser tests.
Documentation for `EarmarkAstDsl`.

### `tag`

The most general helper is the tag function:

    iex(1)> tag("div", "Some content")
    {"div", [], ["Some content"], %{}}

Content and attributes can be provided as arrays, ...

    iex(2)> tag("p", ~w[Hello World], class: "hidden")
    {"p", [{"class", "hidden"}], ["Hello", "World"], %{}}

... or maps:

    iex(3)> tag("p", ~w[Hello World], %{class: "hidden"})
    {"p", [{"class", "hidden"}], ["Hello", "World"], %{}}
      

### Shortcuts for `p` and `div`

    iex(4)> p("A para")
    {"p", [], ["A para"], %{}}

    iex(5)> div(tag("span", "content"))
    {"div", [], [{"span", [], ["content"], %{}}], %{}}



### Tables

Tables are probably the _raison d'être_ ot this little lib, as their ast is quite verbose, as we will see
here:

    iex(6)> table("one cell only") # and look at the output 
    {"table", [], [
      {"tbody", [], [
        {"tr", [], [
          {"td", [{"style", "text-align: left;"}], ["one cell only"], %{}}
        ], %{}}
      ], %{}}
    ], %{}}

Now if we want a header and have some more data:

    iex(7)> table([~w[1-1 1-2], ~w[2-1 2-2]], head: ~w[left right]) # This is quite verbose!
    {"table", [], [
      {"thead", [], [
        {"tr", [], [
          {"th", [{"style", "text-align: left;"}], ["left"], %{}},
          {"th", [{"style", "text-align: left;"}], ["right"], %{}},
        ], %{}}
      ], %{}},
      {"tbody", [], [
        {"tr", [], [
          {"td", [{"style", "text-align: left;"}], ["1-1"], %{}},
          {"td", [{"style", "text-align: left;"}], ["1-2"], %{}},
        ], %{}},
        {"tr", [], [
          {"td", [{"style", "text-align: left;"}], ["2-1"], %{}},
          {"td", [{"style", "text-align: left;"}], ["2-2"], %{}},
        ], %{}}
      ], %{}}
    ], %{}}

And tables can easily be aligned differently in Markdown, which makes some style helpers
very useful

    iex(8)> table([~w[1-1 1-2], ~w[2-1 2-2]],
    ...(8)>        head: ~w[alpha beta],
    ...(8)>        text_aligns: ~w[right center])
    {"table", [], [
      {"thead", [], [
        {"tr", [], [
          {"th", [{"style", "text-align: right;"}], ["alpha"], %{}},
          {"th", [{"style", "text-align: center;"}], ["beta"], %{}},
        ], %{}}
      ], %{}},
      {"tbody", [], [
        {"tr", [], [
          {"td", [{"style", "text-align: right;"}], ["1-1"], %{}},
          {"td", [{"style", "text-align: center;"}], ["1-2"], %{}},
        ], %{}},
        {"tr", [], [
          {"td", [{"style", "text-align: right;"}], ["2-1"], %{}},
          {"td", [{"style", "text-align: center;"}], ["2-2"], %{}},
        ], %{}}
      ], %{}}
    ], %{}}

  Some leeway is given for the determination of the number of columns,
  bear in mind that Markdown only supports regularly shaped tables with
  a fixed number of columns.

  Problems might arise when we have a table like the following

          | alpha        |
          | beta *gamma* |
  
  where the first cell contains one element, but the second two, we can
  hint that we only want one by grouping into tuples

      iex(9)> table(["alpha", {"beta", tag("em", "gamma")}])
      {"table", [], [
        {"tbody", [], [
          {"tr", [], [
            {"td", [{"style", "text-align: left;"}], ["alpha"], %{}},
          ], %{}},
          {"tr", [], [
            {"td", [{"style", "text-align: left;"}], ["beta", {"em", [], ["gamma"], %{}}], %{}}
          ], %{}}
        ], %{}}
      ], %{}}




Same doc can be found here (for latest release)

[https://hexdocs.pm/earmark_ast_dsl](https://hexdocs.pm/earmark_ast_dsl).

## Author

Copyright © 2020 Robert Dober
mailto: robert.dober@gmail.com

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0
