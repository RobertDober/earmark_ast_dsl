defmodule EarmarkAstDsl.Types do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @type att_t :: {binary(), binary()}
      @type att_ts :: list(att_t)
      @type att_list :: list({any() | binary(), binary()})
      @type general_t :: map() | att_list()

      @type content_t :: binary() | list()
      @type ast_node :: ast_t() | binary()
      @type ast_t :: { binary(), att_ts(), list(ast_node()) }

      @type maybe(t) :: t | nil
    end
  end
end
