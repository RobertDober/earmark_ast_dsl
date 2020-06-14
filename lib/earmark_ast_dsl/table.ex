defmodule EarmarkAstDsl.Table do
  @moduledoc false

  use EarmarkAstDsl.Types
  import EarmarkAstDsl.Atts, only: [to_attributes: 1]

  @spec make_table_rows(content_t(), free_atts_t()) :: ast_ts()
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

  @spec _make_table_body(content_t(), map()) :: ast_t()
  defp _make_table_body(rows, atts) do
    {"tbody", [],
     rows
     |> Enum.map(&_make_table_row(&1, atts))}
  end

  @spec _make_table_cell(content_t(), map(), binary()) :: ast_t()
  defp _make_table_cell(cell, atts, tag \\ "td")

  defp _make_table_cell(cell, atts, tag) when is_binary(cell),
    do: _make_table_cell([cell], atts, tag)

  defp _make_table_cell(cell, atts, tag) do
    style = Map.get(atts, :style, "text-align: left;")
    {tag, [{"style", style}], cell}
  end

  @spec _make_table_head(content_t(), map()) :: maybe(ast_t())
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

  @spec _make_table_row(content_t(), map()) :: ast_t()
  defp _make_table_row(row, atts)
  defp _make_table_row(row, atts) when is_binary(row), do: _make_table_row([row], atts)

  defp _make_table_row(row, atts) do
    {"tr", [],
     row
     |> Enum.map(&_make_table_cell(&1, atts))}
  end
end
