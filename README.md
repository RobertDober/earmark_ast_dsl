<!--
DO NOT EDIT THIS FILE
It has been generated from the template `README.md.eex` by Extractly (https://github.com/RobertDober/extractly.git)
and any changes you make in this file will most likely be lost
-->


## EarmarkAstDsl


[![CI](https://github.com/RobertDober/earmark_ast_dsl/actions/workflows/ci.yml/badge.svg)](https://github.com/RobertDober/earmark_ast_dsl/actions/workflows/ci.yml)
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

```elixir
    iex(1)> tag("div", "Some content")
    {"div", [], ["Some content"], %{}}
```

Content and attributes can be provided as arrays, ...

```elixir
    iex(2)> tag("p", ~w[Hello World], class: "hidden")
    {"p", [{"class", "hidden"}], ["Hello", "World"], %{}}
```

... or maps:

```elixir
    iex(3)> tag("p", ~w[Hello World], %{class: "hidden"})
    {"p", [{"class", "hidden"}], ["Hello", "World"], %{}}
```

#### Annotations (as implemented in `EarmarkParser` >= v1.4.16)

In order to not overload tha API for `tag/2`, `tag/3` and `tag/4` we offer the general
`tag_annotated` function

```elixir
    iex(4)> tag_annotated("header", "content", "annotation")
    {"header", [], ["content"], %{annotation: "annotation"}}
```

in this case atts come last

```elixir
    iex(5)> tag_annotated("header", "content", "annotation", class: "two")
    {"header", [{"class", "two"}], ["content"], %{annotation: "annotation"}}
```

### Shortcuts for common tags (`a`, `div`, `li`, `p`)

```elixir
    iex(6)> a("hello", href: "mylink")
    {"a", [{"href", "mylink"}], ["hello"], %{}}
```

```elixir
    iex(7)> p("A para")
    {"p", [], ["A para"], %{}}
```

```elixir
    iex(8)> div(tag("span", "content"))
    {"div", [], [{"span", [], ["content"], %{}}], %{}}
```

```elixir
    iex(9)> li(p("hello"))
    {"li", [], [{"p", [], ["hello"], %{}}], %{}}
```

### Pluriel form for paragraphs `tags`

```elixir
    iex(10)> tags("p", ~W[a b c])
    [{"p", [], ["a"], %{}},
      {"p", [], ["b"], %{}},
      {"p", [], ["c"], %{}}]
```

More helpers, which are less common are described on their functiondocs



### EarmarkAstDsl.blockquote/2

  A convenient shortcut for the often occurring `<blockquoye><p>` tag chain

```elixir
    iex(11)> blockquote("Importante!")
    {"blockquote", [], [{"p", [], ["Importante!"], %{}}], %{}}
```

  All passed in attributes go to the `blockquote` tag

```elixir
    iex(12)> blockquote("Très important", lang: "fr")
    {"blockquote", [{"lang", "fr"}], [{"p", [], ["Très important"], %{}}], %{}}
```


### EarmarkAstDsl.div_annotated/3


```elixir
    iex(13)> div_annotated("content", "special", class: "special_class")
    {"div", [{"class", "special_class"}], ["content"], %{annotation: "special"}}
```

```elixir
    iex(14)> div_annotated("content", "special")
    {"div", [], ["content"], %{annotation: "special"}}
```


### EarmarkAstDsl.inline_code/2


```elixir
    iex(14)> inline_code("with x <- great_value() do")
    {"code", [{"class", "inline"}], ["with x <- great_value() do"], %{}}
```


### EarmarkAstDsl.lis/1

Creates a list of `li` itmes

```elixir
    iex(15)> lis(~W[alpha beta gamma])
    [{"li", [], ["alpha"], %{}},
    {"li", [], ["beta"], %{}},
    {"li", [], ["gamma"], %{}}]
```

Which can typically be used in, well, a list

```elixir
    iex(16)> tag("ol", lis(["a", p("b")]))
    {"ol", [], [{"li", [], ["a"], %{}}, {"li", [], [{"p", [], ["b"], %{}}], %{}}], %{}}
```

### EarmarkAstDsl.ol/2

The `ol` helper is different in respect to other helpers as it wraps content elements into `li` tags if
necessary

```elixir
    iex(17)> ol(["hello", "world"])
    {"ol", [], [{"li", [], ["hello"], %{}}, {"li", [], ["world"], %{}}], %{}}
```

but as mentioned _only_ if necessary so that we can refine `li` elements with attributes or meta if we want

```elixir
    iex(18)> ol(["hello", li("world", class: "global")])
    {"ol", [], [{"li", [], ["hello"], %{}}, {"li", [{"class", "global"}], ["world"], %{}}], %{}}
```

if there is only one `li` no list needs to be passed in

```elixir
    iex(19)> ol("hello")
    {"ol", [], [{"li", [], ["hello"], %{}}], %{}}
```

### EarmarkAstDsl.p_annotated/3


```elixir
    iex(20)> p_annotated("text", "annotation")
    {"p", [], ["text"], %{annotation: "annotation"}}
```


### EarmarkAstDsl.pre_code/2


  A convenient shortcut for the often occurring `<pre><code>` tag chain

```elixir
    iex(21)> pre_code("hello")
    {"pre", [], [{"code", [], ["hello"], %{}}], %{}}
```


### EarmarkAstDsl.pre_code_annotated/3

The annotation adding helper

```elixir
    iex(22)> pre_code_annotated("code", "@@lang=elixir")
    {"pre", [], [{"code", [], ["code"], %{annotation: "@@lang=elixir"}}], %{}}
```

### EarmarkAstDsl.table/2

### Tables

Tables are probably the _raison d'être_ ot this little lib, as their ast is quite verbose, as we will see
here:

```elixir
    iex(26)> table("one cell only") # and look at the output
    {"table", [], [
      {"tbody", [], [
        {"tr", [], [
          {"td", [{"style", "text-align: left;"}], ["one cell only"], %{}}
        ], %{}}
      ], %{}}
    ], %{}}
```

Now if we want a header and have some more data:

```elixir
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
```

And tables can easily be aligned differently in Markdown, which makes some style helpers
very useful

```elixir
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
```

  Some leeway is given for the determination of the number of columns,
  bear in mind that Markdown only supports regularly shaped tables with
  a fixed number of columns.

  Problems might arise when we have a table like the following

          | alpha        |
          | beta *gamma* |

  where the first cell contains one element, but the second two, we can
  hint that we only want one by grouping into tuples

```elixir
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
```


### EarmarkAstDsl.tag/4

This is the base helper which emits a tag with its content, attributes and metadata can be added
at the user's convenience

```elixir
      iex(30)> tag("div")
      {"div", [], [], %{}}
```

With content,

```elixir
      iex(31)> tag("span", "hello")
      {"span", [], ["hello"], %{}}
```

... and attributes,

```elixir
      iex(32)> tag("code", "let it(:be_light)", [class: "inline"])
      {"code", [{"class", "inline"}], ["let it(:be_light)"], %{}}
```

... and metadata

```elixir
      iex(33)> tag("div", "content", [], %{verbatim: true})
      {"div", [], ["content"], %{verbatim: true}}
```

### EarmarkAstDsl.tag_annotated/4

A convience function for easy addition of an annotation to the meta map

### EarmarkAstDsl.ul/2

The `ul` helper is different in respect to other helpers as it wraps content elements into `li` tags if
necessary

```elixir
    iex(23)> ul(["hello", "world"])
    {"ul", [], [{"li", [], ["hello"], %{}}, {"li", [], ["world"], %{}}], %{}}
```

but as mentioned _only_ if necessary so that we can refine `li` elements with attributes or meta if we want

```elixir
    iex(24)> ul(["hello", li("world", class: "global")])
    {"ul", [], [{"li", [], ["hello"], %{}}, {"li", [{"class", "global"}], ["world"], %{}}], %{}}
```

if there is only one `li` no list needs to be passed in

```elixir
    iex(25)> ul("hello")
    {"ul", [], [{"li", [], ["hello"], %{}}] , %{}}
```


### EarmarkAstDsl.void_tag/2

Void tags are just convenient shortcats for calls to `tag` with the second argument
`nil` or `[]`

One cannot pass metadata to a void_tag call


```elixir
      iex(34)> void_tag("hr")
      {"hr", [], [], %{}}
```

```elixir
      iex(35)> void_tag("hr", class: "thin")
      {"hr", [{"class", "thin"}], [], %{}}
```

### EarmarkAstDsl.void_tag_annotated/3

Again the annotated version is available

```elixir
      iex(36)> void_tag_annotated("br", "// break")
      {"br", [], [], %{annotation: "// break"}}
```

```elixir
      iex(37)> void_tag_annotated("wbr", "// for printer", class: "nine")
      {"wbr", [{"class", "nine"}], [], %{annotation: "// for printer"}}
```

### EarmarkAstDsl.vtag/3

vtags are tags from verbatim html

```elixir
      iex(38)> vtag("div", "hello")
      {"div", [], ["hello"], %{verbatim: true}}
```

Attributes can be provided, of course

```elixir
      iex(39)> vtag("div", ["some", "content"], [{"data-lang", "elixir"}])
      {"div", [{"data-lang", "elixir"}], ["some", "content"], %{verbatim: true}}
```

### EarmarkAstDsl.vtag_annotated/4

Verbatim tags still can be annotated and therefore we have this helper

```elixir
    iex(40)> vtag_annotated("i", "emphasized", "-- verbatim", printer: "no")
    {"i", [{"printer", "no"}], ["emphasized"], %{annotation: "-- verbatim", verbatim: true}}
```



Same doc can be found here (for latest release)

[https://hexdocs.pm/earmark_ast_dsl](https://hexdocs.pm/earmark_ast_dsl).

## Author

Copyright © 2020,1 Robert Dober
mailto: robert.dober@gmail.com

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0
