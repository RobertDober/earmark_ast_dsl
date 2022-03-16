defmodule EarmarkAstDsl.Atts do
  @moduledoc false

  use EarmarkAstDsl.Types

  @spec as_list(content_t()) :: maybe(list())
  def as_list(binary_or_list)
  def as_list(binary) when is_binary(binary), do: [binary]
  def as_list(list) when is_list(list), do: list
  def as_list(_), do: nil

  @spec make_atts(list({any(), any()})) :: att_ts()
  def make_atts(atts)
  def make_atts(atts) when is_map(atts) do
    atts
    |> Enum.into([])
    |> make_atts()
  end
  def make_atts(atts) do
    atts
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
  end

  @doc ~S"""
      iex(1)> merge_atts(%{a: 1, b: 2}, b: 3, c: 4)
      [a: 1, b: 3, c: 4]
  """
  @spec merge_atts(free_atts_t(), Keyword.t()) :: Keyword.t()
  def merge_atts(atts, keywords) do
    atts |> Enum.into([]) |> Keyword.merge(keywords)
  end

  @doc """
  A convenience function to filter attributes

      iex(2)> only_atts(%{:a => 1, "b" => 2})
      [{"b", 2}]
  """
  @spec only_atts(free_atts_t()) :: att_ts()
  def only_atts(atts)
  def only_atts(atts) when is_map(atts), do: atts |> Enum.into([]) |> only_atts()
  def only_atts(atts) do
    atts
    |> Enum.filter(&_string_key?/1)
  end

  @doc """
  A convenience function to create attributes in list form

      iex(3)> to_attributes([{"b", 2}, a: 1])
      [{"b", 2}, {"a", 1}]

      iex(4)> to_attributes(%{:a => 1, "b" => 2})
      [{"a", 1}, {"b", 2}]
  """
  @spec to_attributes(free_atts_t()) :: att_ts()
  def to_attributes(atts)
  def to_attributes(atts) when is_list(atts), do: atts |> Enum.map(&_key_to_string/1)
  def to_attributes(atts), do: atts |> Enum.into([]) |> to_attributes()

  @spec _key_to_string({any(), binary()}) :: att_t()
  defp _key_to_string({k, v}), do: {to_string(k), v}

  @spec _string_key?({any(), any()}) :: boolean()
  defp _string_key?(pair)
  defp _string_key?({k, _}), do: is_binary(k)
end
