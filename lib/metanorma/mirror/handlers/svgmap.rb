# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      # SVG image map: a wrapped figure plus the href-overwriting
      # targets that bind the SVG's own links to document anchors.
      # Duck-typed over SafeAttr reads — zero model constants.
      module Svgmap
        REFERENCE_KINDS = %i[xref link eref].freeze

        def self.call(element, context:)
          attrs = {
            id: SafeAttr.read(element, :id),
            semx_id: SafeAttr.read(element, :semx_id),
            links: link_map(element),
          }.compact
          content = figure_content(element, context)
          Handlers.build_node("svgmap", attrs: attrs, content: content)
        end

        def self.figure_content(element, context)
          content = []
          Array(SafeAttr.read(element, :figure)).each do |fig|
            context.registry.handle(fig, context: context).append_to(content)
          end
          content
        end

        def self.link_map(element)
          links = {}
          Array(SafeAttr.read(element, :target)).each do |target|
            href = SafeAttr.read(target, :href)
            links[href] = reference_of(target) if href && !href.empty?
          end
          links.empty? ? nil : links
        end

        def self.reference_of(carrier)
          REFERENCE_KINDS.each do |kind|
            ref = SafeAttr.read(carrier, kind)
            next if ref.nil?

            return SafeAttr.read(ref, :target) ||
                SafeAttr.read(ref, :bibitemid)
          end
          nil
        end
      end
    end
  end
end
