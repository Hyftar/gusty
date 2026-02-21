defmodule Gusty.Registry.Validators do
  @moduledoc """
  Value-type classifiers for disambiguating Tailwind utility classes.

  Used when a prefix like `text-` could map to either font-size or text-color,
  or `border-` could map to border-width or border-color.
  """

  @tailwind_color_names ~w(
    slate gray zinc neutral stone
    red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose
  )

  @css_named_colors ~w(
    black white transparent current inherit
    aliceblue antiquewhite aqua aquamarine azure beige bisque blanchedalmond
    blue blueviolet brown burlywood cadetblue chartreuse chocolate coral
    cornflowerblue cornsilk crimson cyan darkblue darkcyan darkgoldenrod
    darkgray darkgreen darkgrey darkkhaki darkmagenta darkolivegreen darkorange
    darkorchid darkred darksalmon darkseagreen darkslateblue darkslategray
    darkslategrey darkturquoise darkviolet deeppink deepskyblue dimgray dimgrey
    dodgerblue firebrick floralwhite forestgreen fuchsia gainsboro ghostwhite
    gold goldenrod gray green greenyellow grey honeydew hotpink indianred indigo
    ivory khaki lavender lavenderblush lawngreen lemonchiffon lightblue
    lightcoral lightcyan lightgoldenrodyellow lightgray lightgreen lightgrey
    lightpink lightsalmon lightseagreen lightskyblue lightslategray
    lightslategrey lightsteelblue lightyellow lime limegreen linen magenta
    maroon mediumaquamarine mediumblue mediumorchid mediumpurple mediumseagreen
    mediumslateblue mediumspringgreen mediumturquoise mediumvioletred
    midnightblue mintcream mistyrose moccasin navajowhite navy oldlace olive
    olivedrab orange orangered orchid palegoldenrod palegreen paleturquoise
    palevioletred papayawhip peachpuff peru pink plum powderblue purple
    rebeccapurple red rosybrown royalblue saddlebrown salmon sandybrown
    seagreen seashell sienna silver skyblue slateblue slategray slategrey
    snow springgreen steelblue tan teal thistle tomato turquoise violet wheat
    white whitesmoke yellow yellowgreen
  )

  @tshirt_sizes ~w(xs sm base md lg xl 2xl 3xl 4xl 5xl 6xl 7xl 8xl 9xl)

  @doc """
  Returns true if the value looks like a color.

  Matches:
  - Tailwind color names with optional shade (e.g., "red", "red-500")
  - CSS named colors (e.g., "black", "cornflowerblue")
  - Hex colors in arbitrary values (e.g., "#ff0000", "#fff")
  - CSS color functions in arbitrary values (e.g., "rgb(..)", "hsl(..)")
  - Opacity modifier values (e.g., "red-500/50")
  """
  def color?(value) do
    base = value |> String.split("/") |> List.first()

    cond do
      css_named_color?(base) -> true
      tailwind_color?(base) -> true
      hex_color?(base) -> true
      color_function?(base) -> true
      true -> false
    end
  end

  @doc "Returns true if the value is a CSS named color."
  def css_named_color?(value), do: value in @css_named_colors

  @doc "Returns true if the value matches a Tailwind color pattern (e.g., 'red-500')."
  def tailwind_color?(value) do
    case String.split(value, "-", parts: 2) do
      [name] -> name in @tailwind_color_names
      [name, shade] -> name in @tailwind_color_names and shade_value?(shade)
      _ -> false
    end
  end

  defp shade_value?(shade) do
    shade in ~w(50 100 150 200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950)
  end

  defp hex_color?(value) do
    Regex.match?(~r/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/, value)
  end

  defp color_function?(value) do
    String.starts_with?(value, "rgb(") or
      String.starts_with?(value, "rgba(") or
      String.starts_with?(value, "hsl(") or
      String.starts_with?(value, "hsla(") or
      String.starts_with?(value, "oklch(") or
      String.starts_with?(value, "oklab(") or
      String.starts_with?(value, "lab(") or
      String.starts_with?(value, "lch(") or
      String.starts_with?(value, "color(")
  end

  @doc """
  Returns true if the value looks like a length or numeric value.

  Matches: numbers, px, rem, em, %, vw, vh, dvh, svh, lvh, ch, ex, etc.
  """
  def length?(value) do
    number?(value) or
      Regex.match?(
        ~r/^-?\d*\.?\d+(px|rem|em|%|vw|vh|dvw|dvh|svw|svh|lvw|lvh|ch|ex|cap|lh|rlh|vmin|vmax|cqw|cqh|cqi|cqb|cqmin|cqmax)$/,
        value
      )
  end

  @doc "Returns true if the value is a t-shirt size (xs, sm, base, md, lg, xl, 2xl, etc.)."
  def tshirt_size?(value), do: value in @tshirt_sizes

  @doc "Returns true if the value is a plain number (integer or decimal)."
  def number?(value) do
    Regex.match?(~r/^-?\d+\.?\d*$/, value)
  end

  @doc "Returns true if the value looks like an integer (no decimal)."
  def integer?(value) do
    Regex.match?(~r/^-?\d+$/, value)
  end

  @doc "Returns the list of known Tailwind color names."
  def tailwind_color_names, do: @tailwind_color_names

  @doc "Returns the list of known t-shirt sizes."
  def tshirt_sizes, do: @tshirt_sizes
end
