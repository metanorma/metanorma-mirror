# frozen_string_literal: true

module Metanorma
  module Mirror
    # Builds the default handler registry from the registration hooks.
    # Model gems (metanorma-document, metanorma-standoc, flavors) add
    # their class-to-handler entries via Mirror.register_default blocks,
    # run in registration order. The format layer carries no model
    # knowledge (OCP: new model classes register, this file never
    # changes).
    module DefaultRegistry
      class << self
        def build
          registry = HandlerRegistry.new
          Mirror.default_hooks.each do |hook|
            hook.call(registry)
          end
          registry
        end
      end
    end
  end
end
