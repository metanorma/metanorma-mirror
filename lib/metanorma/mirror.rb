# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  # The Mirror format: a lossless JSON projection of a Metanorma
  # document as a typed node tree (blocks, inlines, marks), for
  # renderers and tooling (the SMART document reader, the HTML JS
  # renderer, MKO payload provenance).
  #
  # This gem is format + mechanism only: node models, the handler
  # registry, the transformer walk, serializers, and the output
  # pipeline. Model knowledge (which document classes map to which
  # handlers, marks, renderers, id categories) is REGISTERED by the
  # model gems — metanorma-document and metanorma-standoc seed the
  # defaults at load time via the registration seams below.
  module Mirror
    class Error < StandardError; end

    autoload :VERSION, "#{__dir__}/mirror/version"
    autoload :SafeAttr, "#{__dir__}/mirror/safe_attr"
    autoload :MathUtil, "#{__dir__}/mirror/math_util"
    autoload :Metadata, "#{__dir__}/mirror/metadata"
    autoload :Model, "#{__dir__}/mirror/model"
    autoload :ClassTable, "#{__dir__}/mirror/class_table"
    autoload :HandlerResult, "#{__dir__}/mirror/handler_result"
    autoload :Transformer, "#{__dir__}/mirror/transformer"
    autoload :Rewriter, "#{__dir__}/mirror/rewriter"
    autoload :HandlerRegistry, "#{__dir__}/mirror/handler_registry"
    autoload :Handlers, "#{__dir__}/mirror/handlers"
    autoload :IdStrategy, "#{__dir__}/mirror/id_strategy"
    autoload :Output, "#{__dir__}/mirror/output"
    autoload :Serialization, "#{__dir__}/mirror/serialization"
    autoload :DefaultRegistry, "#{__dir__}/mirror/default_registry"

    DEFAULT_ID_STRATEGY = IdStrategy::Preserve.new

    # Registration seams. Model gems call these at load time so the
    # format layer stays free of model constants:

    # Handler entries for the default registry, in registration order.
    @default_hooks = []

    def self.register_default(&block)
      @default_hooks << block
    end

    def self.default_hooks
      @default_hooks
    end

    # Inline element classes -> mark builders (e.g. EmRawElement ->
    # emphasis mark).
    def self.mark_builders
      @mark_builders ||= ClassTable.new
    end

    # Inline element classes -> rich-HTML renderer lambdas (stem, xref,
    # link, eref, fn, span, br).
    def self.rich_html_renderers
      @rich_html_renderers ||= ClassTable.new
    end

    # Inline element classes -> plain-text substitutions (TabElement ->
    # " ", BrElement -> "\n").
    def self.inline_text_substitutions
      @inline_text_substitutions ||= ClassTable.new
    end

    # Inline element classes -> SIMPLE_WRAPS mark types (see
    # Handlers::Inline::Catalog).
    def self.simple_inline_elements
      @simple_inline_elements ||= ClassTable.new
    end

    # Element classes recognized as semx wrappers (cross-reference
    # carriers); payload is always true.
    def self.semx_elements
      @semx_elements ||= ClassTable.new
    end

    # The mixed-content walker for inline containers: an object
    # responding to each(element) { |node| } yielding semantic children
    # in document order (document seeds register
    # Components::Inline::SemanticContent).
    class << self
      attr_accessor :inline_content_iterator
    end

    def self.default_registry
      @default_registry ||= build_default_registry
    end

    def self.build_default_registry
      DefaultRegistry.build
    end
  end
end
