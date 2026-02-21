defmodule Gusty.MergeTest do
  use ExUnit.Case

  describe "merge/2 - simple conflicts" do
    test "same group last wins" do
      assert Gusty.merge("p-4", "p-2") == "p-2"
    end

    test "different groups both kept" do
      assert Gusty.merge("p-4", "mt-2") == "p-4 mt-2"
    end

    test "font weight conflict" do
      assert Gusty.merge("font-bold", "font-thin") == "font-thin"
    end

    test "bg-color conflict" do
      assert Gusty.merge("bg-blue-500", "bg-red-400") == "bg-red-400"
    end

    test "text color conflict" do
      assert Gusty.merge("text-red-500", "text-blue-200") == "text-blue-200"
    end

    test "display conflict" do
      assert Gusty.merge("flex", "hidden") == "hidden"
    end

    test "position conflict" do
      assert Gusty.merge("absolute", "relative") == "relative"
    end

    test "non-conflicting classes keep all" do
      assert Gusty.merge("font-bold text-black", "bg-white") == "font-bold text-black bg-white"
    end
  end

  describe "merge/2 - shorthand dropped when longhand overrides" do
    test "p shorthand dropped, longhand px wins" do
      assert Gusty.merge("p-4", "px-2") == "px-2"
    end

    test "p shorthand dropped, longhand pt wins" do
      assert Gusty.merge("p-4", "pt-2") == "pt-2"
    end

    test "px shorthand dropped, longhand pr wins" do
      assert Gusty.merge("px-4", "pr-2") == "pr-2"
    end

    test "m shorthand dropped, longhand mx wins" do
      assert Gusty.merge("m-4", "mx-2") == "mx-2"
    end

    test "gap shorthand dropped, longhand gap-x wins" do
      assert Gusty.merge("gap-4", "gap-x-2") == "gap-x-2"
    end

    test "shorthand dropped, explicit longhands both kept" do
      assert Gusty.merge("p-4 px-2", "py-1") == "px-2 py-1"
    end
  end

  describe "merge/2 - shorthand overrides longhands" do
    test "px-2 base + p-4 override replaces px" do
      assert Gusty.merge("px-2", "p-4") == "p-4"
    end

    test "pr-2 pl-2 base + px-4 override" do
      assert Gusty.merge("pr-2 pl-2", "px-4") == "px-4"
    end
  end

  describe "merge/2 - remove: prefix" do
    test "remove:class removes a specific class" do
      assert Gusty.merge("font-bold text-black", "remove:font-bold grid") == "text-black grid"
    end

    test "remove:* clears all base classes" do
      assert Gusty.merge("font-bold text-black", "remove:* grid") == "grid"
    end

    test "remove:class with no match is a no-op" do
      assert Gusty.merge("font-bold text-black", "remove:italic") == "font-bold text-black"
    end
  end

  describe "merge/2 - variants" do
    test "same variant context conflicts" do
      assert Gusty.merge("hover:bg-red-500", "hover:bg-blue-500") == "hover:bg-blue-500"
    end

    test "different variants do not conflict" do
      assert Gusty.merge("hover:bg-red-500", "focus:bg-blue-500") ==
               "hover:bg-red-500 focus:bg-blue-500"
    end

    test "variant order normalization" do
      assert Gusty.merge("dark:hover:bg-red-500", "hover:dark:bg-blue-500") ==
               "hover:dark:bg-blue-500"
    end

    test "base class and variant class do not conflict" do
      assert Gusty.merge("bg-red-500", "hover:bg-blue-500") ==
               "bg-red-500 hover:bg-blue-500"
    end
  end

  describe "merge/2 - override conflicts" do
    test "size-* overrides w-* and h-*" do
      assert Gusty.merge("w-4 h-4", "size-8") == "size-8"
    end

    test "size-* overrides w-* only if h not set" do
      assert Gusty.merge("w-4", "size-8") == "size-8"
    end
  end

  describe "merge/2 - list inputs" do
    test "accepts list as base" do
      assert Gusty.merge(["p-4", "mt-2"], "p-2") == "mt-2 p-2"
    end

    test "accepts list as overrides" do
      assert Gusty.merge("p-4 mt-2", ["p-2"]) == "mt-2 p-2"
    end
  end

  describe "merge/2 - ambiguous prefix resolution" do
    test "text color and font size are distinct groups, both kept" do
      assert Gusty.merge("text-blue-500", "text-sm") == "text-blue-500 text-sm"
    end

    test "text color and font size are distinct groups regardless of order" do
      assert Gusty.merge("text-sm", "text-blue-500") == "text-sm text-blue-500"
    end

    test "text colors conflict with each other" do
      assert Gusty.merge("text-red-500", "text-blue-500") == "text-blue-500"
    end

    test "font sizes conflict with each other" do
      assert Gusty.merge("text-sm", "text-lg") == "text-lg"
    end

    test "border width and border color are distinct groups, both kept" do
      assert Gusty.merge("border-2", "border-red-500") == "border-2 border-red-500"
    end

    test "border width and border color are distinct groups regardless of order" do
      assert Gusty.merge("border-red-500", "border-2") == "border-red-500 border-2"
    end

    test "border widths conflict with each other" do
      assert Gusty.merge("border-2", "border-4") == "border-4"
    end

    test "border colors conflict with each other" do
      assert Gusty.merge("border-red-500", "border-blue-300") == "border-blue-300"
    end

    test "ring width and ring color are distinct groups, both kept" do
      assert Gusty.merge("ring-2", "ring-blue-500") == "ring-2 ring-blue-500"
    end

    test "ring colors conflict with each other" do
      assert Gusty.merge("ring-red-500", "ring-blue-500") == "ring-blue-500"
    end

    test "shadow size and shadow color are distinct groups, both kept" do
      assert Gusty.merge("shadow-lg", "shadow-red-500") == "shadow-lg shadow-red-500"
    end

    test "shadow sizes conflict with each other" do
      assert Gusty.merge("shadow-sm", "shadow-lg") == "shadow-lg"
    end

    test "stroke width and stroke color are distinct groups, both kept" do
      assert Gusty.merge("stroke-2", "stroke-blue-500") == "stroke-2 stroke-blue-500"
    end

    test "stroke widths conflict with each other" do
      assert Gusty.merge("stroke-1", "stroke-2") == "stroke-2"
    end
  end

  describe "merge/2 - tailwind variant prefix (tw:)" do
    test "same group with tw: prefix conflicts" do
      assert Gusty.merge("tw:bg-blue-400", "tw:bg-red-500") == "tw:bg-red-500"
    end

    test "tw: prefix and unprefixed are isolated, both kept" do
      assert Gusty.merge("tw:bg-blue-400", "bg-red-500") == "tw:bg-blue-400 bg-red-500"
    end

    test "shorthand dropped when longhand overrides with tw: prefix" do
      assert Gusty.merge("tw:p-4", "tw:px-2") == "tw:px-2"
    end

    test "shorthand dropped for transitive longhand with tw: prefix" do
      assert Gusty.merge("tw:p-4", "tw:pt-2") == "tw:pt-2"
    end

    test "tw: prefix text color conflict" do
      assert Gusty.merge("tw:text-red-500", "tw:text-blue-200") == "tw:text-blue-200"
    end

    test "tw: prefix does not conflict with hover: prefix" do
      assert Gusty.merge("tw:bg-blue-400", "hover:bg-red-500") ==
               "tw:bg-blue-400 hover:bg-red-500"
    end

    test "tw: combined with md: breakpoint variant conflicts on same group" do
      assert Gusty.merge("tw:md:bg-blue-400", "tw:md:bg-red-500") == "tw:md:bg-red-500"
    end

    test "tw:md: and md: alone are isolated" do
      assert Gusty.merge("tw:md:bg-blue-400", "md:bg-red-500") ==
               "tw:md:bg-blue-400 md:bg-red-500"
    end

    test "tw:md: and tw: alone are isolated" do
      assert Gusty.merge("tw:md:bg-blue-400", "tw:bg-red-500") ==
               "tw:md:bg-blue-400 tw:bg-red-500"
    end

    test "variant order is normalized for conflict detection (tw:md: == md:tw:)" do
      assert Gusty.merge("tw:md:bg-blue-400", "md:tw:bg-red-500") == "md:tw:bg-red-500"
    end

    test "shorthand dropped when longhand overrides with tw:md: prefix" do
      assert Gusty.merge("tw:md:p-4", "tw:md:px-2") == "tw:md:px-2"
    end

    test "shorthand dropped for transitive longhand with tw:md: prefix" do
      assert Gusty.merge("tw:md:p-4", "tw:md:pt-2") == "tw:md:pt-2"
    end
  end

  describe "merge/2 - class prefix (tw-)" do
    setup do
      Application.put_env(:gusty, :class_prefix, "tw-")
      on_exit(fn -> Application.delete_env(:gusty, :class_prefix) end)
    end

    test "same group merges, prefix preserved" do
      assert Gusty.merge("tw-p-4", "tw-p-2") == "tw-p-2"
    end

    test "different groups kept, prefix preserved" do
      assert Gusty.merge("tw-p-4 tw-flex", "tw-m-2") == "tw-p-4 tw-flex tw-m-2"
    end

    test "shorthand dropped when longhand overrides, prefix preserved" do
      assert Gusty.merge("tw-p-4", "tw-px-2") == "tw-px-2"
    end

    test "shorthand dropped for transitive longhand, prefix preserved" do
      assert Gusty.merge("tw-p-4", "tw-pt-2") == "tw-pt-2"
    end

    test "non-prefixed class is still classified and overridden" do
      assert Gusty.merge("p-4", "tw-p-2") == "tw-p-2"
    end

    test "variant + prefix: same variant conflicts" do
      assert Gusty.merge("tw-hover:p-4", "tw-hover:p-2") == "tw-hover:p-2"
    end

    test "variant + prefix: different variants isolated" do
      assert Gusty.merge("tw-hover:p-4", "tw-focus:p-2") == "tw-hover:p-4 tw-focus:p-2"
    end

    test "prefix stripped only from start, not mid-class" do
      assert Gusty.merge("tw-bg-tw-blue", "tw-bg-red-500") == "tw-bg-red-500"
    end
  end

  describe "merge/2 - directional decomposition (decompose: true)" do
    setup do
      Application.put_env(:gusty, :decompose, true)
      on_exit(fn -> Application.delete_env(:gusty, :decompose) end)
    end

    test "p shorthand + px longhand decomposes to py + px" do
      assert Gusty.merge("p-4", "px-2") == "py-4 px-2"
    end

    test "p shorthand + pt longhand decomposes transitively" do
      assert Gusty.merge("p-4", "pt-2") == "px-4 pb-4 pt-2"
    end

    test "px shorthand + pr longhand decomposes to pl + pr" do
      assert Gusty.merge("px-4", "pr-2") == "pl-4 pr-2"
    end

    test "m shorthand + mx longhand decomposes to my + mx" do
      assert Gusty.merge("m-4", "mx-2") == "my-4 mx-2"
    end

    test "gap shorthand + gap-x longhand decomposes to gap-y + gap-x" do
      assert Gusty.merge("gap-4", "gap-x-2") == "gap-y-4 gap-x-2"
    end

    test "shorthand then two longhands" do
      assert Gusty.merge("p-4 px-2", "py-1") == "px-2 py-1"
    end

    test "decomposition with tw: variant prefix" do
      assert Gusty.merge("tw:p-4", "tw:px-2") == "tw:py-4 tw:px-2"
    end

    test "transitive decomposition with tw: variant prefix" do
      assert Gusty.merge("tw:p-4", "tw:pt-2") == "tw:px-4 tw:pb-4 tw:pt-2"
    end
  end
end
