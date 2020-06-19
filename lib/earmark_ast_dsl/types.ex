defmodule EarmarkAstDsl.Types do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @type scalar_t :: binary() | tuple()
      @type vector_t :: list(scalar_t())
      @type matrix_t :: list(vector_t())
      @type row_t    :: vector_t() | scalar_t()
      @type table_t  :: row_t() | matrix_t()

      @type att_t :: {binary(), binary()}
      @type att_ts :: list(att_t)
      @type att_list :: list({any() | binary(), binary()})
      @type free_atts_t :: map() | att_list()

      @type binaries :: list(binary())
      @type content_t :: tuple() | binary() | list()
      @type ast_node :: astv1_t() | binary()
      @type astv1_t :: { binary(), att_ts(), list(ast_node()) }
      @type astv1_ts :: list(astv1_t())
      @type ast_t :: { binary(), att_ts(), list(ast_node()), map() }
      @type ast_ts :: list(ast_t())

      @type maybe(t) :: t | nil
    end
  end
end
