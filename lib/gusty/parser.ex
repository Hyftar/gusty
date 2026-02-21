defmodule Gusty.Parser do
  @moduledoc """
  Parses Tailwind CSS class strings into structured representations.

  Handles variant extraction, important/negative modifiers, opacity modifiers,
  arbitrary values `[...]`, and CSS variable references `(...)` (v4).
  """

  @type parsed_class :: %{
          raw: String.t(),
          class_prefix: String.t(),
          variants: [String.t()],
          variant_key: String.t(),
          base: String.t(),
          important: boolean(),
          negative: boolean(),
          modifier: String.t() | nil,
          arbitrary_value: String.t() | nil,
          arbitrary_variable: String.t() | nil,
          remove: boolean(),
          remove_all: boolean()
        }

  @doc """
  Parses a single class string into a structured map.
  """
  @spec parse(String.t()) :: parsed_class()
  def parse(class) when is_binary(class) do
    {class, remove, remove_all} = parse_remove(class)
    {stripped, class_prefix} = strip_class_prefix(class)
    {variants, base} = split_variants(stripped)
    {base, important} = parse_important(base)
    {base, negative} = parse_negative(base)
    {base, modifier} = parse_modifier(base)
    {base, arbitrary_value} = parse_arbitrary_value(base)
    {base, arbitrary_variable} = parse_arbitrary_variable(base)

    variant_key = Enum.sort(variants) |> Enum.join("|")

    %{
      raw: class,
      class_prefix: class_prefix,
      variants: variants,
      variant_key: variant_key,
      base: base,
      important: important,
      negative: negative,
      modifier: modifier,
      arbitrary_value: arbitrary_value,
      arbitrary_variable: arbitrary_variable,
      remove: remove,
      remove_all: remove_all
    }
  end

  @doc """
  Parses a class string into a list of parsed classes.
  """
  @spec parse_many(String.t()) :: [parsed_class()]
  def parse_many(class_string) when is_binary(class_string) do
    class_string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&parse/1)
  end

  defp strip_class_prefix(class) do
    prefix = Gusty.Config.class_prefix()

    if prefix != "" and String.starts_with?(class, prefix) do
      {String.slice(class, String.length(prefix)..-1//1), prefix}
    else
      {class, ""}
    end
  end

  defp parse_remove("remove:*" <> _rest) do
    {"", false, true}
  end

  defp parse_remove("remove:" <> rest) do
    {rest, true, false}
  end

  defp parse_remove(class) do
    {class, false, false}
  end

  defp split_variants(class) do
    parts = split_on_variant_colons(class)

    case parts do
      [base] -> {[], base}
      parts -> {Enum.slice(parts, 0..-2//1), List.last(parts)}
    end
  end

  defp split_on_variant_colons(class) do
    {parts, current, _depth} =
      class
      |> String.graphemes()
      |> Enum.reduce({[], "", 0}, fn
        "[", {parts, current, depth} ->
          {parts, current <> "[", depth + 1}

        "]", {parts, current, depth} ->
          {parts, current <> "]", max(depth - 1, 0)}

        "(", {parts, current, depth} ->
          {parts, current <> "(", depth + 1}

        ")", {parts, current, depth} ->
          {parts, current <> ")", max(depth - 1, 0)}

        ":", {parts, current, 0} ->
          {parts ++ [current], "", 0}

        char, {parts, current, depth} ->
          {parts, current <> char, depth}
      end)

    parts ++ [current]
  end

  defp parse_important("!" <> rest), do: {rest, true}

  defp parse_important(base) do
    if String.ends_with?(base, "!") do
      {String.slice(base, 0..-2//1), true}
    else
      {base, false}
    end
  end

  defp parse_negative("-" <> rest), do: {rest, true}
  defp parse_negative(base), do: {base, false}

  defp parse_modifier(base) do
    if String.contains?(base, "[") do
      {base, nil}
    else
      case String.split(base, "/", parts: 2) do
        [base_part, mod] when mod != "" -> {base_part, mod}
        _ -> {base, nil}
      end
    end
  end

  defp parse_arbitrary_value(base) do
    case Regex.run(~r/^(.+?)\[(.+)\]$/, base) do
      [_, prefix, value] ->
        prefix = String.trim_trailing(prefix, "-")
        {prefix, value}

      _ ->
        {base, nil}
    end
  end

  defp parse_arbitrary_variable(base) do
    case Regex.run(~r/^(.+?)\((.+)\)$/, base) do
      [_, prefix, value] ->
        prefix = String.trim_trailing(prefix, "-")
        {prefix, value}

      _ ->
        {base, nil}
    end
  end
end
