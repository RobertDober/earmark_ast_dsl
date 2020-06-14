defmodule EarmarkAstDsl do
  import __MODULE__.Table, only: [make_table_rows: 2]
  import __MODULE__.Atts, only: [only_atts: 1]
  @moduledoc """
  EarmarkAstDsl is a toolset to generate EarmarkParser conformant AST Nodes.

  Its main purpose is to remove boilerplate code from Earmark and
  EarmarkParser tests.
  Documentation for `EarmarkAstDsl`.
  """

  def p(content \\ [], atts \\ []), do: tag("p", content, atts)

  def table(rows, atts \\ [])
  def table(rows, atts) when is_binary(rows), do: table([rows], atts)
  def table(rows, atts) do
    tag("table", make_table_rows(rows, atts), only_atts(atts))
  end

  def tag(name, content \\ [], atts \\ [])
  def tag(name, nil, atts), do: tag(name, [], atts)
  def tag(name, content, atts) when is_binary(content) or is_tuple(content),
    do: tag(name, [content], atts)
  def tag(name, content, atts) do
    {to_string(name), _make_atts(atts), content}
  end


  defp _make_atts(atts)
  defp _make_atts(atts) when is_map(atts) do
    atts
    |> Enum.into([])
    |> _make_atts()
  end
  defp _make_atts(atts) do
    atts
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
  end

  defp _make_content(content) do
    content
    |> Enum.map(&to_string/1)
  end
end
