defmodule Gusty.Merger do
  @moduledoc """
  Core merge algorithm for Tailwind CSS classes.

  Handles:
  - Simple group conflicts (same group → last wins)
  - Shorthand drop: longhand overrides shorthand (p-4 + px-2 → px-2)
  - Directional decomposition (opt-in): shorthand split into non-conflicting children
  - Override conflicts (size-* overrides w-* and h-*)
  - remove: and remove:* prefixes
  """

  alias Gusty.Parser
  alias Gusty.Registry.Conflicts

  @doc """
  Merges two class strings. The second argument overrides the first.

  ## Examples

      iex> Gusty.Merger.merge("p-4", "p-2")
      "p-2"

      iex> Gusty.Merger.merge("p-4", "px-2")
      "px-2"

      iex> Gusty.Merger.merge("font-bold text-black", "remove:font-bold grid")
      "text-black grid"
  """
  @spec merge(String.t(), String.t()) :: String.t()
  def merge(base, overrides) when is_binary(base) and is_binary(overrides) do
    base_classes = Parser.parse_many(base)
    override_classes = Parser.parse_many(overrides)

    apply_overrides(base_classes, override_classes)
    |> Enum.map(&reconstruct_class/1)
    |> Enum.join(" ")
  end

  defp apply_overrides(base_classes, override_classes) do
    Enum.reduce(override_classes, base_classes, fn override, acc ->
      cond do
        override.remove_all ->
          []

        override.remove ->
          Enum.reject(acc, fn base ->
            base.base == override.base and base.variant_key == override.variant_key
          end)

        true ->
          apply_single_override(acc, override)
      end
    end)
  end

  defp apply_single_override(base_classes, override) do
    override_group = classify(override)

    case override_group do
      :unknown ->
        base_classes ++ [override]

      group_id ->
        base_classes = apply_override_conflicts(base_classes, group_id, override.variant_key)
        {replaced, new_base} = replace_or_decompose(base_classes, override, group_id)

        if replaced do
          new_base
        else
          base_classes ++ [override]
        end
    end
  end

  defp apply_override_conflicts(base_classes, group_id, variant_key) do
    case Map.get(Conflicts.overrides(), group_id) do
      nil ->
        base_classes

      conflicting_groups ->
        Enum.reject(base_classes, fn base ->
          base_group = classify(base)
          base.variant_key == variant_key and base_group in conflicting_groups
        end)
    end
  end

  defp replace_or_decompose(base_classes, override, override_group) do
    decompositions = Conflicts.decompositions()
    ancestors = Conflicts.ancestors()

    {found, new_base} =
      do_replace_or_decompose(base_classes, override, override_group, decompositions, ancestors, false, [])

    case found do
      true -> {true, new_base ++ [override]}
      false -> {false, base_classes}
    end
  end

  defp do_replace_or_decompose([], _override, _override_group, _decompositions, _ancestors, found, acc) do
    {found, acc}
  end

  defp do_replace_or_decompose([base | rest], override, override_group, decompositions, ancestors, found, acc) do
    base_group = classify(base)

    cond do
      base.variant_key != override.variant_key ->
        do_replace_or_decompose(rest, override, override_group, decompositions, ancestors, found, acc ++ [base])

      base_group == override_group ->
        do_replace_or_decompose(rest, override, override_group, decompositions, ancestors, true, acc)

      is_shorthand_of?(base_group, override_group, decompositions, ancestors) ->
        if Gusty.Config.decompose() do
          decomposed = decompose_shorthand(base, base_group, override_group, decompositions)
          merged_acc = merge_decomposed_into_acc(acc, decomposed, rest, decompositions, ancestors)
          do_replace_or_decompose(rest, override, override_group, decompositions, ancestors, true, merged_acc)
        else
          do_replace_or_decompose(rest, override, override_group, decompositions, ancestors, true, acc)
        end

      is_shorthand_of?(override_group, base_group, decompositions, ancestors) ->
        do_replace_or_decompose(rest, override, override_group, decompositions, ancestors, true, acc)

      true ->
        do_replace_or_decompose(rest, override, override_group, decompositions, ancestors, found, acc ++ [base])
    end
  end

  defp merge_decomposed_into_acc(acc, decomposed, remaining_base_classes, decompositions, ancestors) do
    all_context = acc ++ remaining_base_classes

    Enum.reduce(decomposed, acc, fn child, current_acc ->
      child_group = classify(child)

      conflict_exists =
        Enum.any?(all_context, fn existing ->
          existing.variant_key == child.variant_key and
            (classify(existing) == child_group or
               is_shorthand_of?(child_group, classify(existing), decompositions, ancestors) or
               is_shorthand_of?(classify(existing), child_group, decompositions, ancestors))
        end)

      if conflict_exists do
        current_acc
      else
        current_acc ++ [child]
      end
    end)
  end

  defp is_shorthand_of?(shorthand_group, longhand_group, decompositions, ancestors) do
    case Map.get(ancestors, longhand_group) do
      nil ->
        false

      parent_groups ->
        if shorthand_group in parent_groups do
          true
        else
          Enum.any?(parent_groups, fn parent ->
            is_shorthand_of?(shorthand_group, parent, decompositions, ancestors)
          end)
        end
    end
  end

  defp decompose_shorthand(base, base_group, override_group, decompositions) do
    case Map.get(decompositions, base_group) do
      nil ->
        [base]

      %{children: children, prefix_map: prefix_map} ->
        value = extract_value(base)

        Enum.flat_map(children, fn child_group ->
          child_prefix = Map.fetch!(prefix_map, child_group)
          child_parsed = %{base | base: "#{child_prefix}-#{value}", raw: nil}

          cond do
            child_group == override_group ->
              []

            is_shorthand_of?(child_group, override_group, decompositions, Conflicts.ancestors()) ->
              decompose_shorthand(child_parsed, child_group, override_group, decompositions)

            true ->
              [child_parsed]
          end
        end)
    end
  end

  defp extract_value(%{arbitrary_value: arb}) when not is_nil(arb) do
    "[#{arb}]"
  end

  defp extract_value(%{arbitrary_variable: arb}) when not is_nil(arb) do
    "(#{arb})"
  end

  defp extract_value(%{base: base, negative: negative}) do
    segments = String.split(base, "-")
    trie = Gusty.Registry.trie()
    prefix_length = find_prefix_length(trie, segments, 0)

    value_segments = Enum.drop(segments, prefix_length)
    value = Enum.join(value_segments, "-")

    if negative and value != "", do: "-#{value}", else: value
  end

  defp find_prefix_length(trie, segments, depth) do
    case segments do
      [] ->
        depth

      [segment | rest] ->
        case Map.get(trie, segment) do
          nil ->
            depth

          child ->
            deeper = find_prefix_length(child, rest, depth + 1)

            if Map.has_key?(child, :__groups__) or deeper > depth + 1 do
              deeper
            else
              deeper
            end
        end
    end
  end

  defp classify(parsed) do
    case do_classify(parsed) do
      {:ok, group} -> group
      :unknown -> :unknown
    end
  end

  defp do_classify(%{base: base, arbitrary_value: arb_val, arbitrary_variable: arb_var} = _parsed) do
    case Map.get(Gusty.Registry.enum_map(), base) do
      nil -> classify_by_prefix(base, arb_val, arb_var)
      group_id -> {:ok, group_id}
    end
  end

  defp classify_by_prefix(base, arb_val, arb_var) do
    segments = String.split(base, "-")

    case segments do
      ["text" | rest] when rest != [] ->
        value = Enum.join(rest, "-")
        {:ok, Gusty.Classifier.classify_text(value, arb_val, arb_var)}

      ["border" | rest] when rest != [] ->
        classify_border_segments(rest, arb_val)

      ["ring" | rest] when rest != [] ->
        value = Enum.join(rest, "-")

        case rest do
          ["offset" | _] ->
            Gusty.Classifier.classify(%{base: base, arbitrary_value: arb_val, arbitrary_variable: arb_var})

          _ ->
            {:ok, Gusty.Classifier.classify_ring(value, arb_val)}
        end

      ["shadow" | rest] when rest != [] ->
        value = Enum.join(rest, "-")
        {:ok, Gusty.Classifier.classify_shadow(value, arb_val)}

      ["stroke" | rest] when rest != [] ->
        value = Enum.join(rest, "-")
        {:ok, Gusty.Classifier.classify_stroke(value, arb_val)}

      ["bg" | rest] when rest != [] ->
        classify_bg_segments(rest, arb_val, arb_var)

      ["outline" | rest] when rest != [] ->
        classify_outline_segments(rest, arb_val)

      ["divide" | rest] when rest != [] ->
        classify_divide_segments(rest, arb_val)

      _ ->
        Gusty.Classifier.classify(%{base: base, arbitrary_value: arb_val, arbitrary_variable: arb_var})
    end
  end

  defp classify_border_segments(rest, arb_val) do
    case rest do
      [style] when style in ~w(solid dashed dotted double hidden none) ->
        {:ok, :border_style}

      ["collapse"] -> {:ok, :border_collapse}
      ["separate"] -> {:ok, :border_separate}

      ["spacing" | _] ->
        Gusty.Classifier.classify(%{base: "border-#{Enum.join(rest, "-")}", arbitrary_value: arb_val, arbitrary_variable: nil})

      [dir | value_parts] when dir in ~w(x y t r b l s e) ->
        value = Enum.join(value_parts, "-")
        {:ok, Gusty.Classifier.classify_border(value, dir, arb_val)}

      value_parts ->
        value = Enum.join(value_parts, "-")
        {:ok, Gusty.Classifier.classify_border(value, nil, arb_val)}
    end
  end

  defp classify_bg_segments(rest, _arb_val, _arb_var) do
    case rest do
      [val] when val in ~w(fixed local scroll) -> {:ok, :bg_attachment}
      ["clip" | _] -> {:ok, :bg_clip}
      ["origin" | _] -> {:ok, :bg_origin}
      [val] when val in ~w(bottom center left right top) -> {:ok, :bg_position}
      [v1, v2] when v1 in ~w(left right) and v2 in ~w(bottom top) -> {:ok, :bg_position}
      [val] when val in ~w(repeat no-repeat repeat-x repeat-y repeat-round repeat-space) -> {:ok, :bg_repeat}
      [val] when val in ~w(auto cover contain) -> {:ok, :bg_size}
      ["none"] -> {:ok, :bg_image}
      ["gradient", "to" | _] -> {:ok, :gradient_direction}
      ["linear" | _] -> {:ok, :gradient_direction}
      ["conic" | _] -> {:ok, :bg_conic}
      ["radial" | _] -> {:ok, :bg_radial}
      ["blend" | _] -> {:ok, :bg_blend}
      _ -> {:ok, :bg_color}
    end
  end

  defp classify_outline_segments(rest, _arb_val) do
    case rest do
      [val] when val in ~w(none hidden dashed dotted double) -> {:ok, :outline_style}
      ["offset" | _] -> {:ok, :outline_offset}
      _ ->
        value = Enum.join(rest, "-")

        if Gusty.Registry.Validators.number?(value) do
          {:ok, :outline_w}
        else
          {:ok, :outline_color}
        end
    end
  end

  defp classify_divide_segments(rest, _arb_val) do
    case rest do
      ["x" | _] -> {:ok, :divide_x}
      ["y" | _] -> {:ok, :divide_y}
      [val] when val in ~w(solid dashed dotted double none) -> {:ok, :divide_style}
      _ -> {:ok, :divide_color}
    end
  end

  defp reconstruct_class(%{raw: raw}) when is_binary(raw), do: raw

  defp reconstruct_class(parsed) do
    base =
      cond do
        parsed.arbitrary_value -> "#{parsed.base}-[#{parsed.arbitrary_value}]"
        parsed.arbitrary_variable -> "#{parsed.base}-(#{parsed.arbitrary_variable})"
        true -> parsed.base
      end

    base = if parsed.negative, do: "-#{base}", else: base
    base = if parsed.modifier, do: "#{base}/#{parsed.modifier}", else: base
    base = if parsed.important, do: "#{base}!", else: base

    variant_prefix = Enum.map_join(parsed.variants, "", &"#{&1}:")

    "#{parsed.class_prefix}#{variant_prefix}#{base}"
  end
end
