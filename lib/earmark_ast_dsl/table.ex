defmodule EarmarkAstDsl.Table do
  @moduledoc false

  use EarmarkAstDsl.Types
  import EarmarkAstDsl.Atts, only: [to_attributes: 1]

  def make_table_rows(rows, atts)

  def make_table_rows(rows, atts) when is_list(atts) do
    make_table_rows(
      rows,
      atts
      |> Enum.into(%{})
    )
  end

  def make_table_rows(rows, atts) do
    case _make_table_head(Map.get(atts, :head), atts) do
      nil -> _make_table_body(rows, atts)
      head -> [head, _make_table_body(rows, atts)]
    end
  end

  defp _make_table_body(rows, atts) do
    {"tbody", [],
     rows
     |> Enum.map(&_make_table_row(&1, atts))}
  end

  defp _make_table_cell(cell, atts, tag \\ "td")

  defp _make_table_cell(cell, atts, tag) when is_binary(cell),
    do: _make_table_cell([cell], atts, tag)

  defp _make_table_cell(cell, atts, tag) do
    style = Map.get(atts, :style, "text-align: left;")
    {tag, [{"style", style}], cell}
  end

  defp _make_table_head(celles, atts)
  defp _make_table_head(nil, _atts), do: nil

  defp _make_table_head(cells, atts) do
    atts1 = Map.delete(atts, :head) |> to_attributes()

    {"thead", atts1,
     [
       {"tr", atts1,
        cells
        |> Enum.map(&_make_table_cell(&1, atts, "th"))}
     ]}
  end

  defp _make_table_row(row, atts)
  defp _make_table_row(row, atts) when is_binary(row), do: _make_table_row([row], atts)

  defp _make_table_row(row, atts) do
    {"tr", [],
     row
     |> Enum.map(&_make_table_cell(&1, atts))}
  end
end
