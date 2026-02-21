defmodule Gusty.Config do
  @moduledoc """
  Runtime configuration for Gusty.

  ## Configuration options

      # Add custom color names for disambiguation
      config :gusty, :custom_colors, ["primary", "secondary", "brand-blue"]

      # Classes that should never be merged (always kept)
      config :gusty, :no_merge_classes, ["custom-utility"]

      # Tailwind class prefix (e.g., "tw-" if using prefix: 'tw-' in tailwind.config)
      config :gusty, :class_prefix, "tw-"

      # Enable directional decomposition (default: false — opt-in only, see README)
      config :gusty, :decompose, true
  """

  @doc "Returns the list of custom color names."
  def custom_colors do
    Application.get_env(:gusty, :custom_colors, [])
  end

  @doc "Returns the list of classes that should not be merged."
  def no_merge_classes do
    Application.get_env(:gusty, :no_merge_classes, [])
  end

  @doc "Returns the configured class prefix (e.g., \"tw-\"), or empty string if none."
  def class_prefix do
    Application.get_env(:gusty, :class_prefix, "")
  end

  @doc "Returns true if directional decomposition is enabled (default: false)."
  def decompose do
    Application.get_env(:gusty, :decompose, false)
  end
end
