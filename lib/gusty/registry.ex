defmodule Gusty.Registry do
  @moduledoc """
  Compiles group definitions into a prefix trie at compile time.

  The trie is a nested map where keys are dash-separated segments of class
  prefixes and leaf nodes contain `{:group, group_id}` or
  `{:group, group_id, valid_values}` entries.
  """

  alias Gusty.Registry.Groups

  @doc """
  Returns the compiled prefix trie.

  The trie is a nested map. Walking it with the dash-separated segments of a
  class gives you candidate group matches. Nodes may contain:

  - `{:groups, list}` — list of `{group_id, valid_values | nil}` for prefix groups
  - nested maps for deeper prefix segments
  """
  def trie, do: build_trie(Groups.all())

  @doc """
  Returns the enum lookup map.

  Maps exact class names to their group IDs for enumerated groups.
  """
  def enum_map, do: build_enum_map(Groups.all())

  @doc false
  def build_trie(groups) do
    groups
    |> Enum.filter(fn
      {:prefix, _, _, _} -> true
      {:prefix, _, _} -> true
      _ -> false
    end)
    |> Enum.reduce(%{}, fn group, trie ->
      {_type, group_id, segments} = extract_prefix_info(group)
      valid_values = extract_valid_values(group)
      insert_into_trie(trie, segments, group_id, valid_values)
    end)
  end

  @doc false
  def build_enum_map(groups) do
    groups
    |> Enum.filter(fn
      {:enum, _, _} -> true
      _ -> false
    end)
    |> Enum.reduce(%{}, fn {:enum, group_id, class_names}, acc ->
      Enum.reduce(class_names, acc, fn name, inner ->
        Map.put(inner, name, group_id)
      end)
    end)
  end

  defp extract_prefix_info({:prefix, group_id, segments}), do: {:prefix, group_id, segments}
  defp extract_prefix_info({:prefix, group_id, segments, _}), do: {:prefix, group_id, segments}

  defp extract_valid_values({:prefix, _, _, valid_values}), do: valid_values
  defp extract_valid_values({:prefix, _, _}), do: nil

  defp insert_into_trie(trie, segments, group_id, valid_values) do
    path = segments

    update_nested(trie, path, fn node ->
      existing = Map.get(node, :__groups__, [])
      Map.put(node, :__groups__, [{group_id, valid_values} | existing])
    end)
  end

  defp update_nested(map, [], updater) do
    updater.(map)
  end

  defp update_nested(map, [segment | rest], updater) do
    child = Map.get(map, segment, %{})
    Map.put(map, segment, update_nested(child, rest, updater))
  end
end
