# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        autoload :TextExtractor, "#{__dir__}/inline/text_extractor"
        autoload :RichHtmlRenderer, "#{__dir__}/inline/rich_html_renderer"
        autoload :Catalog, "#{__dir__}/inline/catalog"

        SEMX_MARK_CONFIG = {
          "xref" => { mark_type: "xref", target_attr: :target,
                      fmt_attr: :fmt_xref },
          "eref" => { mark_type: "eref", target_attr: :target,
                      fmt_attr: :fmt_xref },
          "link" => { mark_type: "link", target_attr: :target,
                      fmt_attr: :fmt_link },
        }.freeze

        CROSSREF_MARKS = %w[xref eref link].to_set.freeze

        # Delegates to TextExtractor
        def self.extract_element_text(element)
          TextExtractor.extract_element_text(element)
        end

        def self.extract_formatted_text(element)
          TextExtractor.extract_formatted_text(element)
        end

        def self.extract_text_from_model(node)
          TextExtractor.extract_text_from_model(node)
        end

        # Delegates to RichHtmlRenderer
        def self.extract_rich_html(element)
          RichHtmlRenderer.extract(element)
        end

        # Primary entry point: extract inline content from a mixed-content element.
        # Iterates semantic children only — `fmt-*` rendered siblings are skipped
        # to avoid emitting duplicate marks for the same logical content.
        def self.extract_inline(element, context:)
          nodes = []
          iterator = Mirror.inline_content_iterator or
            raise Error, "no inline content iterator registered; " \
                         "the document seed must provide one"
          iterator.each(element) do |node|
            case node
            when String
              nodes << context.text_node(node) unless node.empty?
            else
              handle_inline_element(node, nodes, context:)
            end
          end
          filter_empty_crossrefs(nodes)
        end

        def self.handle_inline_element(element, nodes, context:)
          if semx_element?(element)
            handle_semx(element, nodes, context:)
            return
          end

          if block_in_inline?(element, context)
            handle_block_in_inline(element, nodes, context:)
            return
          end

          mark_builder = Mirror.mark_builders.lookup(element)
          if mark_builder
            mark = mark_builder.call(element)
            text = extract_marked_text(mark.type, element)
            nodes << context.text_node(text, marks: [mark])
          else
            handle_structured_inline(element, nodes, context:)
          end
        end

        def self.handle_semx(element, nodes, context:)
          config = SEMX_MARK_CONFIG[element.element_attr]
          if config
            handle_semx_crossref(element, config, nodes, context:)
          else
            handle_structured_inline(element, nodes, context:)
          end
        end

        def self.handle_semx_crossref(element, config, nodes, context:)
          fmt_children = SafeAttr.read(element, config[:fmt_attr])
          fmt_child = fmt_children&.first

          mark_attrs = {}
          if fmt_child && config[:target_attr]
            mark_attrs[config[:target_attr]] = SafeAttr.read(fmt_child, :target)
          end

          if element.element_attr == "eref" && fmt_child
            mark_attrs[:citeas] = extract_formatted_text(fmt_child)
          end

          text = extract_formatted_text(fmt_child || element)
          mark = Handlers.build_mark(config[:mark_type],
                                     attrs: mark_attrs.compact)
          nodes << context.text_node(text, marks: [mark])
        end

        def self.handle_block_in_inline(element, nodes, context:)
          result = context.registry.handle(element, context: context)
          result.append_to(nodes)
        end

        def self.handle_structured_inline(element, nodes, context:)
          if element.is_a?(Lutaml::Model::Serializable)
            inner_nodes = extract_inline(element, context:)
            nodes.concat(inner_nodes)
          else
            text = element.text
            nodes << context.text_node(text) if text.is_a?(String) && !text.strip.empty?
          end
        end

        def self.mark_text_extractors
          @mark_text_extractors ||= {
            "footnote" => TextExtractor.method(:extract_fn_label),
            "stem" => TextExtractor.method(:extract_stem_text),
            "span" => TextExtractor.method(:extract_span_text),
          }
        end

        def self.extract_marked_text(mark_type, element)
          extractor = mark_text_extractors[mark_type]
          return extractor.call(element) if extractor

          TextExtractor.extract_element_text(element)
        end

        def self.semx_element?(element)
          !Mirror.semx_elements.lookup(element).nil?
        end

        def self.block_in_inline?(element, context)
          context.registry.registered?(element.class)
        end

        def self.filter_empty_crossrefs(nodes)
          nodes.reject do |n|
            n.is_a?(Model::Text) && n.text.strip.empty? &&
              n.marks.any? { |m| CROSSREF_MARKS.include?(m.type) }
          end
        end
      end
    end
  end
end
