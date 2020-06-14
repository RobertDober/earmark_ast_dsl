defmodule EarmarkAstDsl.Atts do
  @moduledoc false

  use EarmarkAstDsl.Types

  @spec only_atts(general_t()) :: att_ts()
  def only_atts(atts)
  def only_atts(atts) when is_map(atts), do: atts |> Enum.into([]) |> only_atts()
  def only_atts(atts) do
    atts
    |> Enum.filter(&_string_key?/1)
  end

  @spec to_attributes(general_t()) :: att_ts()
  def to_attributes(atts)
  def to_attributes(atts) when is_list(atts), do: atts
  def to_attributes(atts), do: atts |> Enum.into([]) |> Enum.map(&_key_to_string/1)

  @spec _key_to_string({any(), binary()}) :: att_t()
  defp _key_to_string({k, v}), do: {to_string(k), v}

  @spec _string_key?({any(), any()}) :: boolean()
  defp _string_key?(pair)
  defp _string_key?({k, _}), do: is_binary(k)
end
