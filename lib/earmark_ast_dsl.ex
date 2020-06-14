defmodule EarmarkAstDsl do
  import __MODULE__.Table, only: [make_table_rows: 2]
  import __MODULE__.Atts, only: [make_atts: 1, only_atts: 1]

  use EarmarkAstDsl.Types

  @moduledoc """
  EarmarkAstDsl is a toolset to generate EarmarkParser conformant AST Nodes.

  Its main purpose is to remove boilerplate code from Earmark and
  EarmarkParser tests.
  Documentation for `EarmarkAstDsl`.
  """

  @spec p(content_t(), free_atts_t()) :: ast_t()
  def p(content \\ [], atts \\ []), do: tag("p", content, atts)

  @spec table(content_t(), free_atts_t()) :: ast_t()
  def table(rows, atts \\ [])
  def table(rows, atts) when is_binary(rows), do: table([rows], atts)

  def table(rows, atts) do
    tag("table", make_table_rows(rows, atts), only_atts(atts))
  end

  @spec tag(maybe(binary()), content_t(), free_atts_t()) :: ast_t()
  def tag(name, content \\ [], atts \\ [])
  def tag(name, nil, atts), do: tag(name, [], atts)

  def tag(name, content, atts) when is_binary(content) or is_tuple(content),
    do: tag(name, [content], atts)

  def tag(name, content, atts) do
    {to_string(name), make_atts(atts), content}
  end
end
