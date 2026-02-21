defmodule Gusty.Registry.Conflicts do
  @moduledoc """
  Defines shorthand → longhand decomposition rules and additional conflict mappings.

  When merging classes, a longhand class (e.g., `px-2`) may need to decompose
  a shorthand class (e.g., `p-4`) into its component longhands so that only
  the conflicting axis is overridden.

  Also defines "override" conflicts where one group completely replaces another
  (e.g., `size-*` overrides both `w-*` and `h-*`).
  """

  @doc """
  Returns the decomposition map.

  Each key is a shorthand group ID. The value is a map with:
  - `:children` — list of direct child group IDs
  - `:prefix_map` — maps each child group to its prefix string for reconstruction

  When a longhand override targets a child of this shorthand, the shorthand
  is decomposed: replaced by all children except the one being overridden.
  """
  def decompositions do
    %{
      p: %{children: [:px, :py], prefix_map: %{px: "px", py: "py"}},
      px: %{children: [:pr, :pl], prefix_map: %{pr: "pr", pl: "pl"}},
      py: %{children: [:pt, :pb], prefix_map: %{pt: "pt", pb: "pb"}},

      m: %{children: [:mx, :my], prefix_map: %{mx: "mx", my: "my"}},
      mx: %{children: [:mr, :ml], prefix_map: %{mr: "mr", ml: "ml"}},
      my: %{children: [:mt, :mb], prefix_map: %{mt: "mt", mb: "mb"}},

      inset: %{children: [:inset_x, :inset_y], prefix_map: %{inset_x: "inset-x", inset_y: "inset-y"}},
      inset_x: %{children: [:right, :left], prefix_map: %{right: "right", left: "left"}},
      inset_y: %{children: [:top, :bottom], prefix_map: %{top: "top", bottom: "bottom"}},

      gap: %{children: [:gap_x, :gap_y], prefix_map: %{gap_x: "gap-x", gap_y: "gap-y"}},

      border_w: %{
        children: [:border_w_x, :border_w_y],
        prefix_map: %{border_w_x: "border-x", border_w_y: "border-y"}
      },
      border_w_x: %{children: [:border_w_r, :border_w_l], prefix_map: %{border_w_r: "border-r", border_w_l: "border-l"}},
      border_w_y: %{children: [:border_w_t, :border_w_b], prefix_map: %{border_w_t: "border-t", border_w_b: "border-b"}},

      border_color: %{
        children: [:border_color_x, :border_color_y],
        prefix_map: %{border_color_x: "border-x", border_color_y: "border-y"}
      },
      border_color_x: %{
        children: [:border_color_r, :border_color_l],
        prefix_map: %{border_color_r: "border-r", border_color_l: "border-l"}
      },
      border_color_y: %{
        children: [:border_color_t, :border_color_b],
        prefix_map: %{border_color_t: "border-t", border_color_b: "border-b"}
      },

      rounded: %{
        children: [:rounded_t, :rounded_r, :rounded_b, :rounded_l],
        prefix_map: %{rounded_t: "rounded-t", rounded_r: "rounded-r", rounded_b: "rounded-b", rounded_l: "rounded-l"}
      },
      rounded_t: %{children: [:rounded_tl, :rounded_tr], prefix_map: %{rounded_tl: "rounded-tl", rounded_tr: "rounded-tr"}},
      rounded_r: %{children: [:rounded_tr, :rounded_br], prefix_map: %{rounded_tr: "rounded-tr", rounded_br: "rounded-br"}},
      rounded_b: %{children: [:rounded_bl, :rounded_br], prefix_map: %{rounded_bl: "rounded-bl", rounded_br: "rounded-br"}},
      rounded_l: %{children: [:rounded_tl, :rounded_bl], prefix_map: %{rounded_tl: "rounded-tl", rounded_bl: "rounded-bl"}},

      overflow: %{children: [:overflow_x, :overflow_y], prefix_map: %{overflow_x: "overflow-x", overflow_y: "overflow-y"}},

      overscroll: %{children: [:overscroll_x, :overscroll_y], prefix_map: %{overscroll_x: "overscroll-x", overscroll_y: "overscroll-y"}},

      scale: %{children: [:scale_x, :scale_y], prefix_map: %{scale_x: "scale-x", scale_y: "scale-y"}},

      translate: %{children: [:translate_x, :translate_y, :translate_z], prefix_map: %{translate_x: "translate-x", translate_y: "translate-y", translate_z: "translate-z"}},

      scroll_m: %{children: [:scroll_mx, :scroll_my], prefix_map: %{scroll_mx: "scroll-mx", scroll_my: "scroll-my"}},
      scroll_mx: %{children: [:scroll_mr, :scroll_ml], prefix_map: %{scroll_mr: "scroll-mr", scroll_ml: "scroll-ml"}},
      scroll_my: %{children: [:scroll_mt, :scroll_mb], prefix_map: %{scroll_mt: "scroll-mt", scroll_mb: "scroll-mb"}},

      scroll_p: %{children: [:scroll_px, :scroll_py], prefix_map: %{scroll_px: "scroll-px", scroll_py: "scroll-py"}},
      scroll_px: %{children: [:scroll_pr, :scroll_pl], prefix_map: %{scroll_pr: "scroll-pr", scroll_pl: "scroll-pl"}},
      scroll_py: %{children: [:scroll_pt, :scroll_pb], prefix_map: %{scroll_pt: "scroll-pt", scroll_pb: "scroll-pb"}},

      border_spacing: %{
        children: [:border_spacing_x, :border_spacing_y],
        prefix_map: %{border_spacing_x: "border-spacing-x", border_spacing_y: "border-spacing-y"}
      }
    }
  end

  @doc """
  Returns override conflict rules.

  Each key is a group that, when present as an override, should remove all
  classes belonging to the listed groups from the base.
  """
  def overrides do
    %{
      size: [:w, :h],
      flex: [:basis, :grow, :shrink],
      line_clamp: [:display, :overflow, :overflow_x, :overflow_y],
      fvn_normal: [:fvn_ordinal, :fvn_slashed_zero, :fvn_figure, :fvn_spacing, :fvn_fraction],
      fvn_ordinal: [:fvn_normal],
      fvn_slashed_zero: [:fvn_normal],
      fvn_figure: [:fvn_normal],
      fvn_spacing: [:fvn_normal],
      fvn_fraction: [:fvn_normal],
      translate_none: [:translate, :translate_x, :translate_y, :translate_z]
    }
  end

  @doc """
  Returns the ancestry map: for each group, list all ancestor (shorthand) groups.

  Used to check if a base class is a shorthand ancestor of an override's group.
  """
  def ancestors do
    decomps = decompositions()

    Enum.reduce(decomps, %{}, fn {parent, %{children: children}}, acc ->
      Enum.reduce(children, acc, fn child, inner_acc ->
        Map.update(inner_acc, child, [parent], &[parent | &1])
      end)
    end)
  end
end
