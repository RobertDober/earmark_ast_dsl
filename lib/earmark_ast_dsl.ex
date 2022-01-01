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

  #### Annotations (as implemented in `EarmarkParser` >= v1.4.16)

  In order to not overload tha API for `tag/2`, `tag/3` and `tag/4` we offer the general
  `tag_annotated` function

      iex(4)> tag_annotated("header", "content", "annotation")
      {"header", [], ["content"], %{annotation: "annotation"}}

  in this case atts come last

      iex(5)> tag_annotated("header", "content", "annotation", class: "two")
      {"header", [{"class", "two"}], ["content"], %{annotation: "annotation"}}

  ### Shortcuts for common tags (`a`, `div`, `li`, `p`)

      iex(6)> a("hello", href: "mylink")
      {"a", [{"href", "mylink"}], ["hello"], %{}}

      iex(7)> p("A para")
      {"p", [], ["A para"], %{}}

      iex(8)> div(tag("span", "content"))
      {"div", [], [{"span", [], ["content"], %{}}], %{}}

      iex(9)> li(p("hello"))
      {"li", [], [{"p", [], ["hello"], %{}}], %{}}

  ### Pluriel form for paragraphs `tags`

      iex(10)> tags("p", ~W[a b c])
      [{"p", [], ["a"], %{}},
        {"p", [], ["b"], %{}},
        {"p", [], ["c"], %{}}]

  More helpers, which are less common are described on their functiondocs
  """

  @spec a(content_t(), free_atts_t()) :: ast_t()
  def a(content, atts), do: tag("a", content, atts)

  @doc ~S"""
    A convenient shortcut for the often occurring `<blockquoye><p>` tag chain

      iex(11)> blockquote("Importante!")
      {"blockquote", [], [{"p", [], ["Importante!"], %{}}], %{}}

    All passed in attributes go to the `blockquote` tag

      iex(12)> blockquote("Très important", lang: "fr")
      {"blockquote", [{"lang", "fr"}], [{"p", [], ["Très important"], %{}}], %{}}

  """
  @spec blockquote(content_t(), free_atts_t()) :: ast_t()
  def blockquote(content, atts \\ []), do: tag("blockquote", p(content), atts)

  @spec div(content_t(), free_atts_t()) :: ast_t()
  def div(content \\ [], atts \\ []), do: tag("div", content, atts)

  @spec div_annotated(content_t(), any(), free_atts_t()) :: ast_t()
  @doc ~S"""

      iex(13)> div_annotated("content", "special", class: "special_class")
      {"div", [{"class", "special_class"}], ["content"], %{annotation: "special"}}

      iex(14)> div_annotated("content", "special")
      {"div", [], ["content"], %{annotation: "special"}}

  """
  def div_annotated(content, annotation, atts \\ []),
    do: tag_annotated("div", content, annotation, atts)

  @spec li(content_t(), free_atts_t()) :: ast_t()
  def li(content \\ [], atts \\ []), do: tag("li", content, atts)

  @doc ~S"""
  Creates a list of `li` itmes

      iex(15)> lis(~W[alpha beta gamma])
      [{"li", [], ["alpha"], %{}},
      {"li", [], ["beta"], %{}},
      {"li", [], ["gamma"], %{}}]

  Which can typically be used in, well, a list

      iex(16)> tag("ol", lis(["a", p("b")]))
      {"ol", [], [{"li", [], ["a"], %{}}, {"li", [], [{"p", [], ["b"], %{}}], %{}}], %{}}
  """
  @spec lis(list(content_t())) :: [ast_t()]
  def lis(content_list) do
    content_list
    |> Enum.map(&tag("li", &1))
  end

  @doc ~S"""
  The `ol` helper is different in respect to other helpers as it wraps content elements into `li` tags if
  necessary

      iex(17)> ol(["hello", "world"])
      {"ol", [], [{"li", [], ["hello"], %{}}, {"li", [], ["world"], %{}}], %{}}

  but as mentioned _only_ if necessary so that we can refine `li` elements with attributes or meta if we want

      iex(18)> ol(["hello", li("world", class: "global")])
      {"ol", [], [{"li", [], ["hello"], %{}}, {"li", [{"class", "global"}], ["world"], %{}}], %{}}

  if there is only one `li` no list needs to be passed in

      iex(19)> ol("hello")
      {"ol", [], [{"li", [], ["hello"], %{}}], %{}}
  """
  @spec ol(content_t(), free_atts_t()) :: ast_t()
  def ol(content \\ [], atts \\ [])

  def ol(content, atts) when is_list(content) do
    tag("ol", content |> Enum.map(&_make_li_wrapper/1), atts)
  end

  def ol(content, atts) do
    ol([content], atts)
  end

  @spec p(content_t(), free_atts_t()) :: ast_t()
  def p(content \\ [], atts \\ []), do: tag("p", content, atts)

  @doc ~S"""

      iex(20)> p_annotated("text", "annotation")
      {"p", [], ["text"], %{annotation: "annotation"}}

  """
  @spec p_annotated(content_t(), any(), free_atts_t()) :: ast_t()
  def p_annotated(content, annotation, atts \\ []),
    do: tag_annotated("p", content, annotation, atts)

  @doc """

    A convenient shortcut for the often occurring `<pre><code>` tag chain

      iex(21)> pre_code("hello")
      {"pre", [], [{"code", [], ["hello"], %{}}], %{}}

  """
  @spec pre_code(content_t(), free_atts_t()) :: ast_t()
  def pre_code(content, atts \\ []) do
    _tag_chain(["pre", "code"], as_list(content), atts)
  end

  @doc """
  The annotation adding helper

      iex(22)> pre_code_annotated("code", "@@lang=elixir")
      {"pre", [], [{"code", [], ["code"], %{annotation: "@@lang=elixir"}}], %{}}
  """
  @spec pre_code_annotated(content_t(), any, free_atts_t()) :: ast_t()
  def pre_code_annotated(content, annotation, atts \\ []) do
    case pre_code(content, atts) do
      {"pre", atts1, [{"code", atts2, content2, meta2}], meta1} ->
        {"pre", atts1, [{"code", atts2, content2, Map.put(meta2, :annotation, annotation)}],
         meta1}
    end
  end

  @doc ~S"""
  The `ul` helper is different in respect to other helpers as it wraps content elements into `li` tags if
  necessary

      iex(23)> ul(["hello", "world"])
      {"ul", [], [{"li", [], ["hello"], %{}}, {"li", [], ["world"], %{}}], %{}}

  but as mentioned _only_ if necessary so that we can refine `li` elements with attributes or meta if we want

      iex(24)> ul(["hello", li("world", class: "global")])
      {"ul", [], [{"li", [], ["hello"], %{}}, {"li", [{"class", "global"}], ["world"], %{}}], %{}}

  if there is only one `li` no list needs to be passed in

      iex(25)> ul("hello")
      {"ul", [], [{"li", [], ["hello"], %{}}] , %{}}

  """
  @spec ul(content_t(), free_atts_t()) :: ast_t()
  def ul(content \\ [], atts \\ [])

  def ul(content, atts) when is_list(content) do
    tag("ul", content |> Enum.map(&_make_li_wrapper/1), atts)
  end

  def ul(content, atts) do
    ul([content], atts)
  end

  @doc """
  ### Tables

  Tables are probably the _raison d'être_ ot this little lib, as their ast is quite verbose, as we will see
  here:

      iex(26)> table("one cell only") # and look at the output
      {"table", [], [
        {"tbody", [], [
          {"tr", [], [
            {"td", [{"style", "text-align: left;"}], ["one cell only"], %{}}
          ], %{}}
        ], %{}}
      ], %{}}

  Now if we want a header and have some more data:

      iex(27)> table([~w[1-1 1-2], ~w[2-1 2-2]], head: ~w[left right]) # This is quite verbose!
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

      iex(28)> table([~w[1-1 1-2], ~w[2-1 2-2]],
      ...(28)>        head: ~w[alpha beta],
      ...(28)>        text_aligns: ~w[right center])
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

        iex(29)> table(["alpha", {"beta", tag("em", "gamma")}])
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

        iex(30)> tag("div")
        {"div", [], [], %{}}

  With content,

        iex(31)> tag("span", "hello")
        {"span", [], ["hello"], %{}}

  ... and attributes,

        iex(32)> tag("code", "let it(:be_light)", [class: "inline"])
        {"code", [{"class", "inline"}], ["let it(:be_light)"], %{}}

  ... and metadata

        iex(33)> tag("div", "content", [], %{verbatim: true})
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

  @spec tags(maybe(binary()), list(), free_atts_t(), map()) :: list(ast_t())
  def tags(name, content, atts \\ [], meta \\ %{}) do
    content
    |> Enum.map(&tag(name, &1, atts, meta))
  end

  @doc """
  A convience function for easy addition of an annotation to the meta map
  """
  @spec tag_annotated(binary(), maybe(content_t()), any(), free_atts_t()) :: ast_t()
  def tag_annotated(name, content, annotation, atts \\ []),
    do: tag(name, content, atts, %{annotation: annotation})

  @doc """
  Void tags are just convenient shortcats for calls to `tag` with the second argument
  `nil` or `[]`

  One cannot pass metadata to a void_tag call


        iex(34)> void_tag("hr")
        {"hr", [], [], %{}}

        iex(35)> void_tag("hr", class: "thin")
        {"hr", [{"class", "thin"}], [], %{}}
  """
  @spec void_tag(binary(), free_atts_t()) :: ast_t()
  def void_tag(name, atts \\ [])

  def void_tag(name, atts) do
    tag(name, nil, atts)
  end

  @doc """
  Again the annotated version is available

        iex(36)> void_tag_annotated("br", "// break")
        {"br", [], [], %{annotation: "// break"}}

        iex(37)> void_tag_annotated("wbr", "// for printer", class: "nine")
        {"wbr", [{"class", "nine"}], [], %{annotation: "// for printer"}}
  """
  @spec void_tag_annotated(binary(), any(), free_atts_t()) :: ast_t()
  def void_tag_annotated(name, annotation, atts \\ []),
    do: tag_annotated(name, nil, annotation, atts)

  @doc """
  vtags are tags from verbatim html

        iex(38)> vtag("div", "hello")
        {"div", [], ["hello"], %{verbatim: true}}

  Attributes can be provided, of course

        iex(39)> vtag("div", ["some", "content"], [{"data-lang", "elixir"}])
        {"div", [{"data-lang", "elixir"}], ["some", "content"], %{verbatim: true}}
  """
  @spec vtag(maybe(binary()), maybe(content_t()), free_atts_t()) :: ast_t()
  def vtag(name, content \\ [], atts \\ [])

  def vtag(name, content, atts) do
    tag(name, content, atts, %{verbatim: true})
  end

  @doc """
  Verbatim tags still can be annotated and therefore we have this helper

      iex(40)> vtag_annotated("i", "emphasized", "-- verbatim", printer: "no")
      {"i", [{"printer", "no"}], ["emphasized"], %{annotation: "-- verbatim", verbatim: true}}
  """
  @spec vtag_annotated(binary(), maybe(content_t()), any(), free_atts_t()) :: ast_t()
  def vtag_annotated(name, content, annotation, atts \\ []) do
    tag(name, content, atts, %{annotation: annotation, verbatim: true})
  end

  @spec _make_li_wrapper(binary() | tuple()) :: ast_t()
  defp _make_li_wrapper(content_element)
  defp _make_li_wrapper({"li", _, _, _} = li), do: li

  defp _make_li_wrapper(content_element) do
    tag("li", content_element)
  end

  @spec _tag_chain(list(String.t()), content_t(), free_atts_t()) :: ast_t()
  defp _tag_chain(tags, content, atts) do
    tags
    |> Enum.reverse()
    |> Enum.reduce(content, fn next, content -> [{next, make_atts(atts), content, %{}}] end)
    |> hd()
  end
end

#  SPDX-License-Identifier: Apache-2.0
