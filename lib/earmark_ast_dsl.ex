defmodule EarmarkAstDsl do
  import __MODULE__.Table, only: [make_table: 2]
  import __MODULE__.Atts, only: [as_list: 1, make_atts: 1, only_atts: 1]

  use EarmarkAstDsl.Types

  @moduledoc """

[![CI](https://github.com/RobertDober/earmark_ast_dsl/workflows/CI/badge.svg)](https://github.com/RobertDober/earmark_ast_dsl/actions)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/earmark_ast_dsl/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/earmark_ast_dsl?branch=master)
  [![Hex.pm](https://img.shields.io/hexpm/v/earmark_ast_dsl.svg)](https://hex.pm/packages/earmark_ast_dsl)
  [![Hex.pm](https://img.shields.io/hexpm/dw/earmark_ast_dsl.svg)](https://hex.pm/packages/earmark_ast_dsl)
  [![Hex.pm](https://img.shields.io/hexpm/dt/earmark_ast_dsl.svg)](https://hex.pm/packages/earmark_ast_dsl)

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

  """

  @spec div(content_t(), free_atts_t()) :: ast_t()
  def div(content \\ [], atts \\ []), do: tag("div", content, atts)

  @spec p(content_t(), free_atts_t()) :: ast_t()
  def p(content \\ [], atts \\ []), do: tag("p", content, atts)

  @doc """

    A convenient shortcut for the often occurring `<pre><code>` tag chain

    iex(6)> pre_code("hello")
    {"pre", [], [{"code", [], ["hello"], %{}}], %{}}
    
  """
  @spec pre_code(content_t(), free_atts_t()) :: ast_t()
  def pre_code(content, atts \\ []) do
    _tag_chain(["pre", "code"], as_list(content), atts)
  end

  @doc """
  ### Tables

  Tables are probably the _raison d'être_ ot this little lib, as their ast is quite verbose, as we will see
  here:

      iex(7)> table("one cell only") # and look at the output 
      {"table", [], [
        {"tbody", [], [
          {"tr", [], [
            {"td", [{"style", "text-align: left;"}], ["one cell only"], %{}}
          ], %{}}
        ], %{}}
      ], %{}}

  Now if we want a header and have some more data:

      iex(8)> table([~w[1-1 1-2], ~w[2-1 2-2]], head: ~w[left right]) # This is quite verbose!
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

      iex(9)> table([~w[1-1 1-2], ~w[2-1 2-2]],
      ...(9)>        head: ~w[alpha beta],
      ...(9)>        text_aligns: ~w[right center])
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

        iex(10)> table(["alpha", {"beta", tag("em", "gamma")}])
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

  """
  @spec table(table_t(), free_atts_t()) :: ast_t()
  def table(rows, atts \\ [])
  def table(rows, atts) when is_binary(rows), do: table([rows], atts)

  def table(rows, atts) do
    tag("table", make_table(rows, atts), only_atts(atts))
  end

  @doc """
  This is the base helper which emits a tag with its content, attributes and metadata can be added
  at the user's convenience

        iex(11)> tag("div")
        {"div", [], [], %{}}

  With content,

        iex(12)> tag("span", "hello")
        {"span", [], ["hello"], %{}}

  ... and attributes,

        iex(13)> tag("code", "let it(:be_light)", [class: "inline"])
        {"code", [{"class", "inline"}], ["let it(:be_light)"], %{}}

  ... and metadata

        iex(14)> tag("div", "content", [], %{verbatim: true})
        {"div", [], ["content"], %{verbatim: true}}
  """
  @spec tag(maybe(binary()), maybe(content_t()), free_atts_t(), map()) :: ast_t()
  def tag(name, content \\ [], atts \\ [], meta \\ %{})
  def tag(name, nil, atts, meta), do: tag(name, [], atts, meta)

  def tag(name, content, atts, meta) when is_binary(content) or is_tuple(content),
    do: tag(name, [content], atts, meta)

  def tag(name, content, atts, meta) do
    {to_string(name), make_atts(atts), content, meta}
  end

  @doc """
  Void tags are just convenient shortcats for calls to `tag` with the second argument
  `nil` or `[]`

  One cannot pass metadata to a void_tag call


        iex(15)> void_tag("hr")
        {"hr", [], [], %{}}

        iex(16)> void_tag("hr", class: "thin")
        {"hr", [{"class", "thin"}], [], %{}}
  """
  @spec void_tag(binary(), free_atts_t()) :: ast_t() 
  def void_tag(name, atts \\ [])
  def void_tag(name, atts) do
    tag(name, nil, atts) 
  end

  @doc """
  vtags are tags from verbatim html

        iex(17)> vtag("div", "hello")
        {"div", [], ["hello"], %{verbatim: true}}

  Attributes can be provided, of course

        iex(18)> vtag("div", ["some", "content"], [{"data-lang", "elixir"}])
        {"div", [{"data-lang", "elixir"}], ["some", "content"], %{verbatim: true}}
  """
  @spec vtag(maybe(binary()), maybe(content_t()), free_atts_t()) :: ast_t()
  def vtag(name, content \\ [], atts \\ [])
  def vtag(name, content, atts) do
    tag(name, content, atts, %{verbatim: true})
  end

  @spec _tag_chain(list(String.t()), content_t(), free_atts_t()) :: ast_t() 
  defp _tag_chain(tags, content, atts) do
    tags
    |> Enum.reverse
    |> Enum.reduce(content, fn next, content -> [{next, make_atts(atts), content, %{}}] end)
    |> hd()
  end
end
