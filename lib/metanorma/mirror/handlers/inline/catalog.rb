# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        # Shared declarative table of inline marks whose HTML rendering is
        # a fixed tag with optional static attrs. It is consumed by
        # RichHtmlRenderer, which renders Metanorma XML elements to HTML
        # directly (the fallback / attribute-value path) during the
        # forward transform into the mirror IR.
        #
        # Marks whose attrs vary per instance (link, xref, eref, span)
        # carry data in mark.attrs and are not in this table; each
        # consumer keeps custom handlers for those.
        module Catalog
          SIMPLE_WRAPS = {
            "emphasis" => { tag: :em },
            "strong" => { tag: :strong },
            "subscript" => { tag: :sub },
            "superscript" => { tag: :sup },
            "code" => { tag: :code },
            "underline" => { tag: :u },
            "strike" => { tag: :s },
            "smallcap" => { tag: :span, style: "font-variant: small-caps" },
            "concept" => { tag: :span, class: "concept" },
            "bcp14" => { tag: :span, class: "bcp14" },
            "footnote" => { tag: :sup, class: "footnote-inline" },
            "stem" => { tag: :span, class: "stem" },
          }.freeze

        end
      end
    end
  end
end
