defmodule Pathex.Lenses.Any do
  @moduledoc """
  Private module for `any()` lens
  > see `Pathex.Lenses.any/0` documentation
  """

  @spec any() :: Pathex.t()
  def any do
    fn
      :view, {%{} = map, func} ->
        :maps.iterator(map)
        |> :maps.next()
        |> case do
          :none -> :error
          {_, v, _} -> func.(v)
        end

      :view, {t, func} when is_tuple(t) and tuple_size(t) > 0 ->
        func.(:erlang.element(1, t))

      :view, {[{a, v} | _], func} when is_atom(a) ->
        func.(v)

      :view, {[v | _], func} ->
        func.(v)

      :update, {%{} = map, func} ->
        :maps.iterator(map)
        |> :maps.next()
        |> case do
          :none ->
            :error

          {key, value, _} ->
            with {:ok, new_value} <- func.(value) do
              {:ok, %{map | key => new_value}}
            end
        end

      :update, {t, func} when is_tuple(t) and tuple_size(t) > 0 ->
        with {:ok, new_element} <- func.(:erlang.element(1, t)) do
          {:ok, :erlang.setelement(1, t, new_element)}
        end

      :update, {[{a, value} | tail], func} when is_atom(a) ->
        with {:ok, new_value} <- func.(value) do
          {:ok, [{a, new_value} | tail]}
        end

      :update, {[value | tail], func} ->
        with {:ok, new_value} <- func.(value) do
          {:ok, [new_value | tail]}
        end

      :force_update, {%{} = map, func, _} ->
        :maps.iterator(map)
        |> :maps.next()
        |> case do
          :none ->
            :error

          {key, value, _} ->
            with {:ok, new_value} <- func.(value) do
              {:ok, %{map | key => new_value}}
            end
        end

      :force_update, {t, func, _} when is_tuple(t) and tuple_size(t) > 0 ->
        with {:ok, new_element} <- func.(:erlang.element(1, t)) do
          {:ok, :erlang.setelement(1, t, new_element)}
        end

      :force_update, {t, _, default} when is_tuple(t) ->
        {:ok, {default}}

      :force_update, {[{a, value} | tail], func, _} when is_atom(a) ->
        with {:ok, new_value} <- func.(value) do
          {:ok, [{a, new_value} | tail]}
        end

      :force_update, {[value | tail], func, _} ->
        with {:ok, new_value} <- func.(value) do
          {:ok, [new_value | tail]}
        end

      :force_update, {[], _, default} ->
        {:ok, [default]}

      op, _ when op in ~w[view update force_update]a ->
        :error
    end
  end
end
