defmodule EarmarkAstDsl.Table do
  @moduledoc false

  use EarmarkAstDsl.Types
  import EarmarkAstDsl.Atts, only: [as_list: 1]

  alias EarmarkAstDsl, as: Dsl

  @spec make_table(table_t(), Keyword.t(head: binaries())) :: ast_ts()
  def make_table(content, atts)

  def make_table(content, atts) when is_list(content) do
    content
    |> Enum.map(&_make_row/1)
    |> _make_table_rows(atts)
  end

  @spec _make_table_rows(matrix_t(), Keyword.t(head: binaries())) :: ast_ts()
  defp _make_table_rows(rows, atts)

  defp _make_table_rows(rows, atts) do
    text_aligns =
      atts
      |> Keyword.get(:text_aligns, "left")
      |> as_list()

    head = Keyword.get(atts, :head) |> as_list()

    case _make_table_head(head, text_aligns) do
      nil -> _make_table_body(rows, text_aligns)
      head -> [head, _make_table_body(rows, text_aligns)]
    end
  end

  @typep aligned_t :: list({scalar_t(), binary()})
  @spec _align_cells(row_t(), binaries()) :: aligned_t()
  defp _align_cells(cells, aligns) do
    aligns1 =
      aligns
      |> Stream.concat(Stream.cycle(~w[left]))

    cells
    |> Stream.zip(aligns1)
    |> Enum.to_list()
  end

  @spec _make_row(row_t()) :: vector_t()
  defp _make_row(row_or_string)
  defp _make_row(string) when is_binary(string), do: [string]
  defp _make_row(row), do: row

  @spec _make_table_body(matrix_t(), binaries()) :: ast_t()
  defp _make_table_body(rows, text_aligns) do
    Dsl.tag("tbody",
      Enum.map(rows, &_make_table_row(&1, text_aligns)))
  end

  @spec _make_table_cell({scalar_t(), binary()}, binary()) :: ast_t()
  defp _make_table_cell(cell, tag)

  defp _make_table_cell({content, align}, tag) when is_tuple(content) do
    Dsl.tag(tag, Tuple.to_list(content), [{"style", "text-align: #{align};"}])
  end

  defp _make_table_cell({content, align}, tag) do
    Dsl.tag(tag, content, [{"style", "text-align: #{align};"}])
  end

  @spec _make_table_head(row_t(), binaries()) :: maybe(ast_t())
  defp _make_table_head(cells, text_aligns)
  defp _make_table_head(nil, _text_aligns), do: nil

  defp _make_table_head(cells, text_aligns) do
    aligned_cells =
      cells
      |> _align_cells(text_aligns)

    tr =
      Dsl.tag("tr", Enum.map(aligned_cells, &_make_table_cell(&1, "th")))

    Dsl.tag("thead", [tr])
  end

  @spec _make_table_row(row_t(), binaries()) :: ast_t()
  defp _make_table_row(row, text_aligns)

  defp _make_table_row(row, text_aligns) when is_tuple(row),
    do: _make_table_row([row], text_aligns)

  defp _make_table_row(row, text_aligns) do
    aligned_cells =
      row
      |> _align_cells(text_aligns)

    Dsl.tag("tr", Enum.map(aligned_cells, &_make_table_cell(&1, "td")))
  end
end
