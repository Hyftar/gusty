defmodule Gusty.Classifier do
  @moduledoc """
  Classifies a parsed Tailwind class into a group ID.

  Uses the registry's prefix trie and enum map, plus special handling for
  ambiguous prefixes (text-*, border-*, ring-*, shadow-*, stroke-*).
  """

  alias Gusty.Registry
  alias Gusty.Registry.Validators

  @doc """
  Classifies a parsed class into a group ID.

  Returns `{:ok, group_id}` or `:unknown`.
  """
  @spec classify(map()) :: {:ok, atom()} | :unknown
  def classify(%{base: base, arbitrary_value: arb_val, arbitrary_variable: arb_var}) do
    case Map.get(Registry.enum_map(), base) do
      nil -> classify_by_prefix(base, arb_val, arb_var)
      group_id -> {:ok, group_id}
    end
  end

  defp classify_by_prefix(base, arb_val, arb_var) do
    segments = String.split(base, "-")
    trie = Registry.trie()

    case walk_trie(trie, segments, nil) do
      {group_id, _valid_values, remaining_segments} when not is_nil(group_id) ->
        resolve_ambiguous(group_id, remaining_segments, arb_val, arb_var)

      _ ->
        :unknown
    end
  end

  defp walk_trie(node, segments, best_match) do
    current_match =
      case Map.get(node, :__groups__) do
        nil -> best_match
        groups -> pick_best_group(groups, segments, best_match)
      end

    case segments do
      [] ->
        current_match

      [segment | rest] ->
        case Map.get(node, segment) do
          nil -> current_match
          child_node -> walk_trie(child_node, rest, current_match)
        end
    end
  end

  defp pick_best_group(groups, remaining_segments, current_best) do
    remaining_value = Enum.join(remaining_segments, "-")

    constrained_match =
      Enum.find_value(groups, fn
        {group_id, valid_values} when is_list(valid_values) ->
          if remaining_value in valid_values, do: {group_id, valid_values, remaining_segments}

        _ ->
          nil
      end)

    if constrained_match do
      constrained_match
    else
      unconstrained =
        Enum.find_value(groups, fn
          {group_id, nil} -> {group_id, nil, remaining_segments}
          _ -> nil
        end)

      unconstrained || current_best
    end
  end

  defp resolve_ambiguous(group_id, _remaining, _arb_val, _arb_var)
       when group_id not in [
              :font_family,
              :font_weight,
              :decoration_color,
              :decoration_style,
              :decoration_thickness,
              :outline_w,
              :outline_color,
              :divide_color,
              :ring_offset_w,
              :ring_offset_color
            ] do
    {:ok, group_id}
  end

  defp resolve_ambiguous(group_id, _remaining, _arb_val, _arb_var) do
    {:ok, group_id}
  end

  @doc """
  Classifies a base class string directly (convenience for testing).
  """
  def classify_base(base) when is_binary(base) do
    parsed = %{base: base, arbitrary_value: nil, arbitrary_variable: nil}
    classify(parsed)
  end

  @doc """
  Classifies ambiguous text-* classes.

  - Known sizes (xs, sm, base, lg, xl, 2xl...) → :font_size
  - Color values → :text_color
  - Arbitrary [length] → :font_size
  - Arbitrary [color] → :text_color
  - Default → :text_color (most common usage)
  """
  def classify_text(value, arb_val \\ nil, arb_var \\ nil) do
    cond do
      arb_val != nil and String.starts_with?(arb_val, "length:") -> :font_size
      arb_val != nil and String.starts_with?(arb_val, "color:") -> :text_color
      arb_var != nil -> :text_color

      arb_val != nil ->
        cond do
          Validators.length?(arb_val) -> :font_size
          Validators.color?(arb_val) -> :text_color
          true -> :text_color
        end

      Validators.tshirt_size?(value) -> :font_size
      Validators.color?(value) -> :text_color
      true -> :text_color
    end
  end

  @doc """
  Classifies ambiguous border-* classes.

  - Numbers/lengths → :border_w (width) with directional variants
  - Colors → :border_color with directional variants
  - Styles → :border_style
  """
  def classify_border(value, direction \\ nil, arb_val \\ nil) do
    group_suffix =
      case direction do
        nil -> ""
        dir -> "_#{dir}"
      end

    cond do
      arb_val != nil and String.starts_with?(arb_val, "length:") ->
        String.to_atom("border_w#{group_suffix}")

      arb_val != nil and String.starts_with?(arb_val, "color:") ->
        String.to_atom("border_color#{group_suffix}")

      arb_val != nil ->
        if Validators.length?(arb_val),
          do: String.to_atom("border_w#{group_suffix}"),
          else: String.to_atom("border_color#{group_suffix}")

      Validators.number?(value) or value == "" ->
        String.to_atom("border_w#{group_suffix}")

      Validators.color?(value) ->
        String.to_atom("border_color#{group_suffix}")

      true ->
        String.to_atom("border_color#{group_suffix}")
    end
  end

  @doc """
  Classifies ambiguous ring-* classes.
  """
  def classify_ring(value, arb_val \\ nil) do
    cond do
      Validators.number?(value) or value == "" -> :ring_w
      arb_val != nil and Validators.length?(arb_val) -> :ring_w
      true -> :ring_color
    end
  end

  @doc """
  Classifies ambiguous shadow-* classes.
  """
  def classify_shadow(value, arb_val \\ nil) do
    cond do
      Validators.tshirt_size?(value) -> :shadow_size
      value in ~w(none inner) -> :shadow_size
      value == "" -> :shadow_size
      arb_val != nil and Validators.color?(arb_val) -> :shadow_color
      Validators.color?(value) -> :shadow_color
      true -> :shadow_size
    end
  end

  @doc """
  Classifies ambiguous stroke-* classes.
  """
  def classify_stroke(value, arb_val \\ nil) do
    cond do
      Validators.number?(value) or value in ~w(0 1 2) -> :stroke_w
      arb_val != nil and Validators.length?(arb_val) -> :stroke_w
      true -> :stroke_color
    end
  end
end
