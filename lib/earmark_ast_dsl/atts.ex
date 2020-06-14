defmodule EarmarkAstDsl.Atts do
  @moduledoc false

  def only_atts(atts)
  def only_atts(atts) when is_map(atts), do: atts |> Enum.into([]) |> only_atts()
  def only_atts(atts) do
    atts
    |> Enum.filter(&_string_key?/1)
  end

  defp _string_key?({k, _}), do: is_binary(k)
end
