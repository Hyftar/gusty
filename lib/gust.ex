defmodule Gust do
  @moduledoc """
  Lightweight Tailwind CSS class merging for Elixir.

  Gust provides utilities for constructing and merging Tailwind CSS class lists,
  handling the gotcha that class attribute order doesn't determine CSS specificity.

  Supports both Tailwind V3 and V4 class naming conventions.

  ## Usage

      # Build class strings with conditional inclusion
      Gust.classes(["p-4", "mt-2", [hidden: is_hidden, "font-bold": is_bold]])

      # Merge classes with intelligent conflict resolution
      Gust.merge("p-4 bg-red-500", "p-2")
      #=> "bg-red-500 p-2"

      # Longhand overrides shorthand: shorthand is dropped
      Gust.merge("p-4", "px-2")
      #=> "px-2"

      # Remove specific classes during merge
      Gust.merge("font-bold text-black", "remove:font-bold grid")
      #=> "text-black grid"

      # Remove all base classes
      Gust.merge("font-bold text-black", "remove:* grid")
      #=> "grid"

  ## Sigil

      import Gust
      ~t"p-4 mt-2"
  """

  alias Gust.Merger

  @doc """
  Builds a class string from mixed inputs with conditional inclusion.

  Accepts strings, lists, and keyword lists. Keyword lists are treated as
  conditional: the key (class name) is included only if the value is truthy.

  ## Examples

      iex> Gust.classes("p-4 mt-2")
      "p-4 mt-2"

      iex> Gust.classes(["p-4", "mt-2"])
      "p-4 mt-2"

      iex> Gust.classes(["p-4", [hidden: true, "font-bold": false]])
      "p-4 hidden"

      iex> Gust.classes(["mt-1 mx-2", ["pt-2": true, "pb-4": false]])
      "mt-1 mx-2 pt-2"
  """
  @spec classes(binary() | list()) :: String.t()
  def classes(input) when is_binary(input), do: input

  def classes(input) when is_list(input) do
    input
    |> flatten_classes()
    |> Enum.join(" ")
  end

  def classes(nil), do: ""

  @doc """
  Merges base classes with override classes.

  The second argument's classes override conflicting classes in the first argument.
  When a longhand overrides a shorthand, the shorthand is dropped (e.g., `p-4` + `px-2` → `px-2`).
  Directional decomposition is available as an opt-in; see `Gust.Config`.

  ## Examples

      iex> Gust.merge("p-4", "p-2")
      "p-2"

      iex> Gust.merge("p-4", "px-2")
      "px-2"

      iex> Gust.merge("font-bold", "font-thin")
      "font-thin"

      iex> Gust.merge("bg-blue-500", "bg-red-400")
      "bg-red-400"
  """
  @spec merge(binary(), binary()) :: String.t()
  def merge(base, overrides) when is_binary(base) and is_binary(overrides) do
    Merger.merge(base, overrides)
  end

  def merge(base, overrides) when is_list(base) do
    merge(classes(base), overrides)
  end

  def merge(base, overrides) when is_list(overrides) do
    merge(base, classes(overrides))
  end

  @doc """
  Removes a specific class from a class string.

  ## Examples

      iex> Gust.remove("p-4 mt-2 font-bold", "mt-2")
      "p-4 font-bold"
  """
  @spec remove(binary(), binary()) :: String.t()
  def remove(class_string, class_to_remove)
      when is_binary(class_string) and is_binary(class_to_remove) do
    class_string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.reject(&(&1 == class_to_remove))
    |> Enum.join(" ")
  end

  @doc """
  Sigil for building class strings. Resolves conflicts in the resulting class string.

  Only use literal class names — Tailwind's scanner must be able to find all class
  names statically. Interpolated values will not be included in the generated stylesheet.

  ## Examples

      iex> import Gust
      iex> ~t"p-4 mt-2"
      "p-4 mt-2"

      iex> import Gust
      iex> ~t"p-4 p-2"
      "p-2"
  """
  defmacro sigil_t({:<<>>, _meta, pieces}, _modifiers) do
    quote do
      Gust.merge("", unquote({:<<>>, [], pieces}))
    end
  end

  defp flatten_classes(items) do
    Enum.flat_map(items, fn
      nil ->
        []

      item when is_binary(item) ->
        item |> String.split(~r/\s+/, trim: true)

      items when is_list(items) ->
        if Keyword.keyword?(items) do
          items
          |> Enum.filter(fn {_key, value} -> value end)
          |> Enum.flat_map(fn {key, _} ->
            key |> to_string() |> String.split(~r/\s+/, trim: true)
          end)
        else
          flatten_classes(items)
        end

      {key, value} ->
        if value do
          key |> to_string() |> String.split(~r/\s+/, trim: true)
        else
          []
        end
    end)
  end
end
