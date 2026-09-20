# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      # Image map: a wrapped figure plus hyperlinked areas (shape,
      # link, geometry). Duck-typed over SafeAttr reads.
      module Imagemap
        def self.call(element, context:)
          attrs = {
            id: SafeAttr.read(element, :id),
            semx_id: SafeAttr.read(element, :semx_id),
            areas: area_list(element),
          }.compact
          content = Svgmap.figure_content(element, context)
          Handlers.build_node("imagemap", attrs: attrs, content: content)
        end

        def self.area_list(element)
          areas = Array(SafeAttr.read(element, :area)).map { |a| area_attrs(a) }
          areas.empty? ? nil : areas
        end

        def self.area_attrs(area)
          ref = Svgmap.reference_of(area)
          radius = SafeAttr.read(area, :radius)
          {
            type: SafeAttr.read(area, :area_type) || SafeAttr.read(area, :type),
            target: ref,
            coords: Array(SafeAttr.read(area, :coords)).map do |c|
              [SafeAttr.read(c, :x), SafeAttr.read(c, :y)]
            end,
            radius: radius && radius_attrs(radius),
          }.compact
        end

        def self.radius_attrs(radius)
          [SafeAttr.read(radius, :x), SafeAttr.read(radius, :y)]
        end
      end
    end
  end
end
