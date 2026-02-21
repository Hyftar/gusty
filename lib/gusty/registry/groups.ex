defmodule Gusty.Registry.Groups do
  @moduledoc """
  Declarative definitions of all Tailwind CSS utility groups.

  Each group represents a set of classes that conflict with each other
  (i.e., only the last one should win when merging). Groups are defined
  in three forms:

  - `{:prefix, group_id, prefix_segments}` — Any class starting with these
    dash-separated segments belongs to this group (e.g., `["bg"]` matches `bg-red-500`).
  - `{:prefix, group_id, prefix_segments, valid_values}` — Same as above but only
    matches if the remaining value is in the given list.
  - `{:enum, group_id, class_names}` — Exact class name matches.

  Supports both Tailwind V3 and V4 class names.
  """

  @doc "Returns all group definitions."
  def all do
    layout() ++
      flexbox_grid() ++
      spacing() ++
      sizing() ++
      typography() ++
      backgrounds() ++
      borders() ++
      effects() ++
      filters() ++
      transforms() ++
      transitions() ++
      interactivity() ++
      svg() ++
      tables() ++
      accessibility()
  end

  defp layout do
    [
      {:enum, :display,
       ~w(block inline-block inline flex inline-flex table inline-table table-caption
          table-cell table-column table-column-group table-footer-group table-header-group
          table-row-group table-row flow-root grid inline-grid contents list-item hidden)},

      {:enum, :position, ~w(static fixed absolute relative sticky)},

      {:enum, :visibility, ~w(visible invisible collapse)},

      {:prefix, :inset, ["inset"]},
      {:prefix, :inset_x, ["inset", "x"]},
      {:prefix, :inset_y, ["inset", "y"]},
      {:prefix, :top, ["top"]},
      {:prefix, :right, ["right"]},
      {:prefix, :bottom, ["bottom"]},
      {:prefix, :left, ["left"]},
      {:prefix, :start, ["start"]},
      {:prefix, :end_, ["end"]},

      {:prefix, :z, ["z"]},

      {:enum, :float, ~w(float-left float-right float-start float-end float-none)},

      {:enum, :clear, ~w(clear-left clear-right clear-start clear-end clear-both clear-none)},

      {:enum, :isolation, ~w(isolate isolation-auto)},

      {:enum, :object_fit, ~w(object-contain object-cover object-fill object-none object-scale-down)},

      {:prefix, :object_position, ["object"],
       ~w(bottom center left left-bottom left-top right right-bottom right-top top)},

      {:prefix, :overflow, ["overflow"], ~w(auto hidden clip visible scroll)},
      {:prefix, :overflow_x, ["overflow", "x"], ~w(auto hidden clip visible scroll)},
      {:prefix, :overflow_y, ["overflow", "y"], ~w(auto hidden clip visible scroll)},

      {:prefix, :overscroll, ["overscroll"], ~w(auto contain none)},
      {:prefix, :overscroll_x, ["overscroll", "x"], ~w(auto contain none)},
      {:prefix, :overscroll_y, ["overscroll", "y"], ~w(auto contain none)},

      {:enum, :box_sizing, ~w(box-border box-content)},

      {:enum, :box_decoration, ~w(box-decoration-slice box-decoration-clone decoration-slice decoration-clone)},

      {:prefix, :aspect, ["aspect"]},

      {:prefix, :columns, ["columns"]},

      {:prefix, :break_before, ["break", "before"]},
      {:prefix, :break_after, ["break", "after"]},
      {:prefix, :break_inside, ["break", "inside"]},

      {:enum, :container, ~w(container)}
    ]
  end

  defp flexbox_grid do
    [
      {:enum, :flex_direction, ~w(flex-row flex-row-reverse flex-col flex-col-reverse)},

      {:enum, :flex_wrap, ~w(flex-wrap flex-wrap-reverse flex-nowrap)},

      {:prefix, :flex, ["flex"], ~w(1 auto initial none)},

      {:prefix, :grow, ["grow"]},
      {:prefix, :grow, ["flex", "grow"]},

      {:prefix, :shrink, ["shrink"]},
      {:prefix, :shrink, ["flex", "shrink"]},

      {:prefix, :basis, ["basis"]},

      {:prefix, :order, ["order"]},

      {:prefix, :grid_cols, ["grid", "cols"]},

      {:prefix, :col_span, ["col", "span"]},
      {:prefix, :col_start, ["col", "start"]},
      {:prefix, :col_end, ["col", "end"]},

      {:prefix, :grid_rows, ["grid", "rows"]},

      {:prefix, :row_span, ["row", "span"]},
      {:prefix, :row_start, ["row", "start"]},
      {:prefix, :row_end, ["row", "end"]},

      {:enum, :grid_flow, ~w(grid-flow-row grid-flow-col grid-flow-dense grid-flow-row-dense grid-flow-col-dense)},

      {:prefix, :auto_cols, ["auto", "cols"]},
      {:prefix, :auto_rows, ["auto", "rows"]},

      {:prefix, :gap, ["gap"]},
      {:prefix, :gap_x, ["gap", "x"]},
      {:prefix, :gap_y, ["gap", "y"]},

      {:prefix, :justify_content, ["justify"],
       ~w(normal start end center between around evenly stretch)},

      {:prefix, :justify_items, ["justify", "items"]},

      {:prefix, :justify_self, ["justify", "self"]},

      {:prefix, :align_content, ["content"],
       ~w(normal center start end between around evenly baseline stretch)},

      {:prefix, :align_items, ["items"]},

      {:prefix, :align_self, ["self"]},

      {:prefix, :place_content, ["place", "content"]},

      {:prefix, :place_items, ["place", "items"]},

      {:prefix, :place_self, ["place", "self"]}
    ]
  end

  defp spacing do
    [
      {:prefix, :p, ["p"]},
      {:prefix, :px, ["px"]},
      {:prefix, :py, ["py"]},
      {:prefix, :ps, ["ps"]},
      {:prefix, :pe, ["pe"]},
      {:prefix, :pt, ["pt"]},
      {:prefix, :pr, ["pr"]},
      {:prefix, :pb, ["pb"]},
      {:prefix, :pl, ["pl"]},

      {:prefix, :m, ["m"]},
      {:prefix, :mx, ["mx"]},
      {:prefix, :my, ["my"]},
      {:prefix, :ms, ["ms"]},
      {:prefix, :me, ["me"]},
      {:prefix, :mt, ["mt"]},
      {:prefix, :mr, ["mr"]},
      {:prefix, :mb, ["mb"]},
      {:prefix, :ml, ["ml"]},

      {:prefix, :space_x, ["space", "x"]},
      {:prefix, :space_y, ["space", "y"]},
      {:enum, :space_x_reverse, ~w(space-x-reverse)},
      {:enum, :space_y_reverse, ~w(space-y-reverse)}
    ]
  end

  defp sizing do
    [
      {:prefix, :size, ["size"]},

      {:prefix, :w, ["w"]},
      {:prefix, :min_w, ["min", "w"]},
      {:prefix, :max_w, ["max", "w"]},

      {:prefix, :h, ["h"]},
      {:prefix, :min_h, ["min", "h"]},
      {:prefix, :max_h, ["max", "h"]}
    ]
  end

  defp typography do
    [
      {:prefix, :font_family, ["font"], ~w(sans serif mono)},

      {:prefix, :font_weight, ["font"],
       ~w(thin extralight light normal medium semibold bold extrabold black)},

      {:enum, :font_style, ~w(italic not-italic)},

      {:prefix, :font_stretch, ["font", "stretch"]},

      {:enum, :font_smoothing, ~w(antialiased subpixel-antialiased)},

      {:enum, :fvn_normal, ~w(normal-nums)},
      {:enum, :fvn_ordinal, ~w(ordinal)},
      {:enum, :fvn_slashed_zero, ~w(slashed-zero)},
      {:enum, :fvn_figure, ~w(lining-nums oldstyle-nums)},
      {:enum, :fvn_spacing, ~w(proportional-nums tabular-nums)},
      {:enum, :fvn_fraction, ~w(diagonal-fractions stacked-fractions)},

      {:prefix, :tracking, ["tracking"]},

      {:prefix, :leading, ["leading"]},

      {:prefix, :line_clamp, ["line", "clamp"]},

      {:enum, :list_style_position, ~w(list-inside list-outside)},

      {:prefix, :list_style_type, ["list"], ~w(none disc decimal)},

      {:prefix, :list_image, ["list", "image"]},

      {:enum, :text_align, ~w(text-left text-center text-right text-justify text-start text-end)},

      {:enum, :text_decoration, ~w(underline overline line-through no-underline)},

      {:prefix, :decoration_color, ["decoration"]},

      {:prefix, :decoration_style, ["decoration"], ~w(solid double dotted dashed wavy)},

      {:prefix, :decoration_thickness, ["decoration"],
       ~w(auto from-font 0 1 2 4 8)},

      {:prefix, :underline_offset, ["underline", "offset"]},

      {:enum, :text_transform, ~w(uppercase lowercase capitalize normal-case)},

      {:enum, :text_overflow, ~w(truncate text-ellipsis text-clip)},

      {:enum, :text_wrap, ~w(text-wrap text-nowrap text-balance text-pretty)},

      {:enum, :overflow_wrap, ~w(wrap-normal wrap-break-word wrap-anywhere)},

      {:prefix, :indent, ["indent"]},

      {:prefix, :vertical_align, ["align"]},

      {:prefix, :whitespace, ["whitespace"]},

      {:enum, :word_break, ~w(break-normal break-all break-keep)},

      {:prefix, :hyphens, ["hyphens"]},

      {:prefix, :content, ["content"]}
    ]
  end

  defp backgrounds do
    [
      {:enum, :bg_attachment, ~w(bg-fixed bg-local bg-scroll)},

      {:enum, :bg_clip, ~w(bg-clip-border bg-clip-padding bg-clip-content bg-clip-text)},

      {:enum, :bg_origin, ~w(bg-origin-border bg-origin-padding bg-origin-content)},

      {:enum, :bg_position,
       ~w(bg-bottom bg-center bg-left bg-left-bottom bg-left-top
          bg-right bg-right-bottom bg-right-top bg-top)},

      {:enum, :bg_repeat,
       ~w(bg-repeat bg-no-repeat bg-repeat-x bg-repeat-y bg-repeat-round bg-repeat-space)},

      {:enum, :bg_size, ~w(bg-auto bg-cover bg-contain)},

      {:enum, :bg_image, ~w(bg-none)},

      {:prefix, :gradient_direction, ["bg", "gradient", "to"]},
      {:prefix, :gradient_direction, ["bg", "linear", "to"]},
      {:prefix, :gradient_direction, ["bg", "linear"]},

      {:prefix, :bg_conic, ["bg", "conic"]},
      {:prefix, :bg_radial, ["bg", "radial"]},

      {:prefix, :from_color, ["from"]},
      {:prefix, :from_position, ["from"], ~w(0% 5% 10% 15% 20% 25% 30% 35% 40% 45% 50% 55% 60% 65% 70% 75% 80% 85% 90% 95% 100%)},

      {:prefix, :via_color, ["via"]},
      {:prefix, :via_position, ["via"], ~w(0% 5% 10% 15% 20% 25% 30% 35% 40% 45% 50% 55% 60% 65% 70% 75% 80% 85% 90% 95% 100%)},

      {:prefix, :to_color, ["to"]},
      {:prefix, :to_position, ["to"], ~w(0% 5% 10% 15% 20% 25% 30% 35% 40% 45% 50% 55% 60% 65% 70% 75% 80% 85% 90% 95% 100%)}
    ]
  end

  defp borders do
    [
      {:prefix, :rounded, ["rounded"]},
      {:prefix, :rounded_s, ["rounded", "s"]},
      {:prefix, :rounded_e, ["rounded", "e"]},
      {:prefix, :rounded_t, ["rounded", "t"]},
      {:prefix, :rounded_r, ["rounded", "r"]},
      {:prefix, :rounded_b, ["rounded", "b"]},
      {:prefix, :rounded_l, ["rounded", "l"]},
      {:prefix, :rounded_ss, ["rounded", "ss"]},
      {:prefix, :rounded_se, ["rounded", "se"]},
      {:prefix, :rounded_ee, ["rounded", "ee"]},
      {:prefix, :rounded_es, ["rounded", "es"]},
      {:prefix, :rounded_tl, ["rounded", "tl"]},
      {:prefix, :rounded_tr, ["rounded", "tr"]},
      {:prefix, :rounded_br, ["rounded", "br"]},
      {:prefix, :rounded_bl, ["rounded", "bl"]},

      {:enum, :border_style,
       ~w(border-solid border-dashed border-dotted border-double border-hidden border-none)},

      {:prefix, :divide_x, ["divide", "x"]},
      {:prefix, :divide_y, ["divide", "y"]},
      {:enum, :divide_x_reverse, ~w(divide-x-reverse)},
      {:enum, :divide_y_reverse, ~w(divide-y-reverse)},

      {:enum, :divide_style,
       ~w(divide-solid divide-dashed divide-dotted divide-double divide-none)},

      {:prefix, :divide_color, ["divide"]},

      {:enum, :outline_style, ~w(outline-none outline-hidden outline outline-dashed outline-dotted outline-double)},

      {:prefix, :outline_w, ["outline"]},

      {:prefix, :outline_color, ["outline"]},

      {:prefix, :outline_offset, ["outline", "offset"]},

      {:prefix, :ring_offset_w, ["ring", "offset"]},

      {:prefix, :ring_offset_color, ["ring", "offset"]},

      {:enum, :ring_inset, ~w(ring-inset)},

      {:prefix, :inset_ring, ["inset", "ring"]}
    ]
  end

  defp effects do
    [
      {:prefix, :inset_shadow, ["inset", "shadow"]},

      {:prefix, :text_shadow, ["text", "shadow"]},

      {:prefix, :opacity, ["opacity"]},

      {:prefix, :mix_blend, ["mix", "blend"]},

      {:prefix, :bg_blend, ["bg", "blend"]}
    ]
  end

  defp filters do
    [
      {:prefix, :blur, ["blur"]},
      {:prefix, :brightness, ["brightness"]},
      {:prefix, :contrast, ["contrast"]},
      {:prefix, :drop_shadow, ["drop", "shadow"]},
      {:prefix, :grayscale, ["grayscale"]},
      {:prefix, :hue_rotate, ["hue", "rotate"]},
      {:prefix, :invert, ["invert"]},
      {:prefix, :saturate, ["saturate"]},
      {:prefix, :sepia, ["sepia"]},

      {:prefix, :backdrop_blur, ["backdrop", "blur"]},
      {:prefix, :backdrop_brightness, ["backdrop", "brightness"]},
      {:prefix, :backdrop_contrast, ["backdrop", "contrast"]},
      {:prefix, :backdrop_grayscale, ["backdrop", "grayscale"]},
      {:prefix, :backdrop_hue_rotate, ["backdrop", "hue", "rotate"]},
      {:prefix, :backdrop_invert, ["backdrop", "invert"]},
      {:prefix, :backdrop_opacity, ["backdrop", "opacity"]},
      {:prefix, :backdrop_saturate, ["backdrop", "saturate"]},
      {:prefix, :backdrop_sepia, ["backdrop", "sepia"]}
    ]
  end

  defp transforms do
    [
      {:enum, :transform, ~w(transform-cpu transform-gpu transform-none transform-3d)},

      {:prefix, :rotate, ["rotate"]},
      {:prefix, :rotate_x, ["rotate", "x"]},
      {:prefix, :rotate_y, ["rotate", "y"]},
      {:prefix, :rotate_z, ["rotate", "z"]},

      {:prefix, :scale, ["scale"]},
      {:prefix, :scale_x, ["scale", "x"]},
      {:prefix, :scale_y, ["scale", "y"]},
      {:prefix, :scale_z, ["scale", "z"]},

      {:prefix, :skew_x, ["skew", "x"]},
      {:prefix, :skew_y, ["skew", "y"]},

      {:prefix, :translate, ["translate"]},
      {:prefix, :translate_x, ["translate", "x"]},
      {:prefix, :translate_y, ["translate", "y"]},
      {:prefix, :translate_z, ["translate", "z"]},
      {:enum, :translate_none, ~w(translate-none)},

      {:prefix, :perspective, ["perspective"]},
      {:prefix, :perspective_origin, ["perspective", "origin"]},

      {:prefix, :transform_origin, ["origin"]},

      {:enum, :backface, ~w(backface-visible backface-hidden)}
    ]
  end

  defp transitions do
    [
      {:enum, :transition_property,
       ~w(transition transition-all transition-colors transition-opacity
          transition-shadow transition-transform transition-none)},

      {:prefix, :duration, ["duration"]},

      {:prefix, :ease, ["ease"]},

      {:prefix, :delay, ["delay"]},

      {:prefix, :animate, ["animate"]}
    ]
  end

  defp interactivity do
    [
      {:prefix, :accent, ["accent"]},

      {:prefix, :appearance, ["appearance"]},

      {:prefix, :caret, ["caret"]},

      {:enum, :color_scheme, ~w(color-scheme-normal color-scheme-dark color-scheme-light)},

      {:prefix, :cursor, ["cursor"]},

      {:enum, :field_sizing, ~w(field-sizing-content field-sizing-fixed)},

      {:enum, :pointer_events, ~w(pointer-events-none pointer-events-auto)},

      {:enum, :resize, ~w(resize-none resize-y resize-x resize)},

      {:enum, :scroll_behavior, ~w(scroll-auto scroll-smooth)},

      {:prefix, :scroll_m, ["scroll", "m"]},
      {:prefix, :scroll_mx, ["scroll", "mx"]},
      {:prefix, :scroll_my, ["scroll", "my"]},
      {:prefix, :scroll_ms, ["scroll", "ms"]},
      {:prefix, :scroll_me, ["scroll", "me"]},
      {:prefix, :scroll_mt, ["scroll", "mt"]},
      {:prefix, :scroll_mr, ["scroll", "mr"]},
      {:prefix, :scroll_mb, ["scroll", "mb"]},
      {:prefix, :scroll_ml, ["scroll", "ml"]},

      {:prefix, :scroll_p, ["scroll", "p"]},
      {:prefix, :scroll_px, ["scroll", "px"]},
      {:prefix, :scroll_py, ["scroll", "py"]},
      {:prefix, :scroll_ps, ["scroll", "ps"]},
      {:prefix, :scroll_pe, ["scroll", "pe"]},
      {:prefix, :scroll_pt, ["scroll", "pt"]},
      {:prefix, :scroll_pr, ["scroll", "pr"]},
      {:prefix, :scroll_pb, ["scroll", "pb"]},
      {:prefix, :scroll_pl, ["scroll", "pl"]},

      {:prefix, :snap_align, ["snap"], ~w(start end center none align-none)},

      {:prefix, :snap_stop, ["snap"], ~w(normal always)},

      {:prefix, :snap_type, ["snap"], ~w(none x y both mandatory proximity)},

      {:enum, :touch, ~w(touch-auto touch-none touch-manipulation)},
      {:enum, :touch_x, ~w(touch-pan-x touch-pan-left touch-pan-right)},
      {:enum, :touch_y, ~w(touch-pan-y touch-pan-up touch-pan-down)},
      {:enum, :touch_pz, ~w(touch-pinch-zoom)},

      {:prefix, :select, ["select"]},

      {:prefix, :will_change, ["will", "change"]}
    ]
  end

  defp svg do
    [
      {:prefix, :fill, ["fill"]}
    ]
  end

  defp tables do
    [
      {:enum, :border_collapse, ~w(border-collapse border-separate)},

      {:prefix, :border_spacing, ["border", "spacing"]},
      {:prefix, :border_spacing_x, ["border", "spacing", "x"]},
      {:prefix, :border_spacing_y, ["border", "spacing", "y"]},

      {:enum, :table_layout, ~w(table-auto table-fixed)},

      {:prefix, :caption, ["caption"]}
    ]
  end

  defp accessibility do
    [
      {:enum, :sr_only, ~w(sr-only not-sr-only)},
      {:enum, :forced_color_adjust, ~w(forced-color-adjust-auto forced-color-adjust-none)}
    ]
  end
end
