# Gusty

Lightweight Tailwind CSS class merging for Elixir. Zero dependencies, no compile-time overhead.

## Why Gusty?

In Tailwind, class order in the HTML attribute doesn't determine which style wins —
the stylesheet order does. This means `"p-4 p-2"` does not reliably apply `p-2`.
You need to deduplicate conflicting classes at the point where you build the string.

Gusty handles this by understanding Tailwind's class groups: it knows that `p-4` and
`p-2` conflict (both set padding), that `p-4` and `px-2` only partially conflict
(one sets all sides, the other only horizontal), and that `bg-red-500` and
`font-bold` don't conflict at all.

The previous Elixir solution for this — [Tails](https://github.com/zachdaniel/tails)
— relied on a compile-time list of 70,000+ pattern-match clauses, causing 8+
seconds of compile time and ~4 GB RAM usage. Gusty replaces this with a runtime
prefix trie built from ~500 lines of declarative group definitions. Lookup is O(k)
in the number of class segments, compile time is negligible.

## Installation

```elixir
def deps do
  [
    {:gusty, "~> 0.1"}
  ]
end
```

## Usage

### `Gusty.merge/2`

Merges two class strings. The second argument overrides the first.

```elixir
# Same group: last wins
Gusty.merge("p-4", "p-2")
#=> "p-2"

# Different groups: both kept
Gusty.merge("p-4", "m-2")
#=> "p-4 m-2"

# Longhand overrides shorthand: shorthand is dropped entirely
Gusty.merge("p-4", "px-2")
#=> "px-2"

# Shorthand overrides longhands: shorthand wins, longhands removed
Gusty.merge("px-2 py-4", "p-8")
#=> "p-8"

# Variants are respected — same group but different variants don't conflict
Gusty.merge("p-4", "hover:p-2")
#=> "p-4 hover:p-2"

# Same variant + same group: overrides
Gusty.merge("hover:p-4", "hover:p-2")
#=> "hover:p-2"

# Override conflicts: size-* replaces both w-* and h-*
Gusty.merge("w-4 h-4", "size-8")
#=> "size-8"
```

Both arguments also accept lists (passed through `Gusty.classes/1` first):

```elixir
Gusty.merge(["p-4", "m-2"], "p-2")
#=> "m-2 p-2"
```

### `Gusty.classes/1`

Builds a class string from a mixed list of strings and conditionals. Classes are merged left-to-right, so later entries win on conflicts.

```elixir
Gusty.classes("p-4 mt-2")
#=> "p-4 mt-2"

Gusty.classes(["p-4", "mt-2"])
#=> "p-4 mt-2"

# Conflicts are resolved: last wins
Gusty.classes(["p-4", "p-2"])
#=> "p-2"

# Longhand overrides shorthand: shorthand is dropped
Gusty.classes(["p-4", "px-2"])
#=> "px-2"

# Keyword lists: key is the class, value is the condition
Gusty.classes(["p-4", [hidden: true, "font-bold": false]])
#=> "p-4 hidden"

# Nested lists and tuples work too
Gusty.classes(["mt-1 mx-2", ["pt-2": true, "pb-4": false]])
#=> "mt-1 mx-2 pt-2"
```

### `Gusty.remove/2`

Removes an exact class from a class string.

```elixir
Gusty.remove("p-4 mt-2 font-bold", "mt-2")
#=> "p-4 font-bold"
```

### `~t` sigil

A string sigil that resolves conflicts in a literal class string. Only use literal class names — Tailwind's scanner must be able to find all class names statically.
Interpolated values will not be included in the generated stylesheet.

```elixir
import Gusty

~t"p-4 mt-2"
#=> "p-4 mt-2"

~t"p-4 p-2"
#=> "p-2"

~t"p-4 px-2"
#=> "px-2"
```

### `remove:` prefix

The `remove:` prefix in the override string removes a class by exact match without adding anything:

```elixir
Gusty.merge("font-bold text-black", "remove:font-bold grid")
#=> "text-black grid"
```

`remove:*` removes all base classes:

```elixir
Gusty.merge("font-bold text-black", "remove:* grid")
#=> "grid"
```

## Ambiguous classes

Several Tailwind prefixes map to more than one CSS property group. Gusty disambiguates them by inspecting the value:

| Prefix     | Possible groups                 | Resolution                                                                |
| ---------- | ------------------------------- | ------------------------------------------------------------------------- |
| `text-*`   | `font_size` or `text_color`     | t-shirt sizes (`sm`, `lg`, `2xl`…) → font size; color values → text color |
| `border-*` | `border_w` or `border_color`    | numbers/lengths → width; color values → color                             |
| `ring-*`   | `ring_w` or `ring_color`        | numbers → width; color values → color                                     |
| `shadow-*` | `shadow_size` or `shadow_color` | t-shirt sizes / `none` / `inner` → size; color values → color             |
| `stroke-*` | `stroke_w` or `stroke_color`    | numbers → width; color values → color                                     |

```elixir
# text-sm (font size) and text-blue-500 (text color) don't conflict
Gusty.merge("text-sm text-blue-500", "text-lg")
#=> "text-blue-500 text-lg"
```

## Variants

Variants (`hover:`, `focus:`, `md:`, `dark:`, etc.) are extracted from each class and used as a conflict scope. Two classes only conflict if they belong to the same group **and** have the same set of variants. Variant order within a class does not affect conflict detection.

```elixir
# md:hover: and hover:md: have the same variant set — they conflict
Gusty.merge("md:hover:p-4", "hover:md:p-2")
#=> "hover:md:p-2"

# Different variant sets — no conflict
Gusty.merge("hover:p-4", "focus:p-2")
#=> "hover:p-4 focus:p-2"
```

## Tailwind class prefix

If you use Tailwind's `prefix` option (e.g., `prefix: 'tw-'` in `tailwind.config.js`), configure Gusty to strip and re-apply it automatically:

```elixir
# config/config.exs
config :gusty, :class_prefix, "tw-"
```

```elixir
Gusty.merge("tw-p-4", "tw-p-2")
#=> "tw-p-2"

Gusty.merge("tw-p-4", "tw-px-2")
#=> "tw-px-2"
```

## Configuration

All options are set via `Application` config:

```elixir
# config/config.exs

# Tailwind class prefix (default: none)
config :gusty, :class_prefix, "tw-"

# Additional color names for disambiguation (default: [])
config :gusty, :custom_colors, ["primary", "secondary", "brand-blue"]

# Classes that are never merged — always kept as-is (default: [])
config :gusty, :no_merge_classes, ["custom-utility"]

# Enable directional decomposition (default: false — see below)
config :gusty, :decompose, true
```

## Directional decomposition

Tailwind's shorthand utilities like `p-*` expand to set all four sides. When a longhand like `px-2` overrides a shorthand like `p-4`, there are two possible strategies:

**Drop (default):** The shorthand is removed and the longhand takes over. Simple, safe, and predictable — Tailwind's scanner only ever sees class names that are literally present in your source.

```elixir
Gusty.merge("p-4", "px-2")
#=> "px-2"
```

**Decompose (opt-in):** The shorthand is split into its non-conflicting children and the override is applied. The result preserves more information, but the decomposed class names (e.g., `py-4`) are generated at runtime — Tailwind's static scanner cannot see them and will not include them in the stylesheet unless they appear elsewhere in your source.

```elixir
# config/config.exs
config :gusty, decompose: true
```

```elixir
Gusty.merge("p-4", "px-2")
#=> "py-4 px-2"   # <!> py-4 must exist in Tailwind's safelist or source scan
```

Only enable decomposition if you are using Tailwind's [safelist](https://tailwindcss.com/docs/content-configuration#safelisting-classes) or can otherwise guarantee all decomposed class names are present in the stylesheet.

Note that the reverse direction — a shorthand overriding existing longhands — always works safely regardless of this setting, because the shorthand class was already present in your source:

```elixir
Gusty.merge("px-2 py-4", "p-8")
#=> "p-8"
```

## How it works

Gusty builds a prefix trie from declarative group definitions at runtime. Each Tailwind utility class maps to a group ID (e.g., `:p`, `:px`, `:bg_color`, `:font_size`). When merging:

1. Both class strings are parsed into structured maps (variants, base, modifiers, arbitrary values).
2. Each class is classified to a group via trie lookup.
3. For each override class, any base class in the same group **and** with the same variant set is removed.
4. If a base class is a shorthand ancestor of the override's group (e.g., `p-4` is an ancestor of `px`), it is dropped (or decomposed if `config :gusty, decompose: true`).
5. The resulting class list is reconstructed into a string.
