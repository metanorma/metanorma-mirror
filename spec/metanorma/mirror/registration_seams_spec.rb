# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma::Mirror registration seams" do
  it "builds the default registry from register_default hooks in order" do
    Metanorma::Mirror.build_default_registry # no hooks: empty registry
    registry = Metanorma::Mirror.build_default_registry
    element_class = Class.new
    callable = ->(_el, **) { :handled }
    Metanorma::Mirror.register_default do |r|
      r.register(element_class, callable)
    end
    registry = Metanorma::Mirror.build_default_registry
    expect(registry).to be_registered(element_class)
    result = registry.handle(element_class.new, context: nil)
    expect(result.none?).to be(false)
    expect(result.nodes).to eq(:handled)
  ensure
    Metanorma::Mirror.default_hooks.pop
  end

  it "exposes the class tables for model-gem seeds" do
    klass = Class.new
    builder = ->(_el) { :mark }
    Metanorma::Mirror.mark_builders.register(klass, builder)
    expect(Metanorma::Mirror.mark_builders.lookup(klass.new)).to eq(builder)

    Metanorma::Mirror.simple_inline_elements.register(klass, "emphasis")
    expect(Metanorma::Mirror.simple_inline_elements.lookup(klass.new))
      .to eq("emphasis")

    Metanorma::Mirror.inline_text_substitutions.register(klass, "\n")
    expect(Metanorma::Mirror.inline_text_substitutions.lookup(klass.new))
      .to eq("\n")

    Metanorma::Mirror.semx_elements.register(klass, true)
    expect(Metanorma::Mirror.semx_elements.lookup(klass.new)).to be(true)
  end

  it "holds an injectable inline content iterator" do
    iterator = Class.new do
      def self.each(element, &block)
        block.call("text from #{element}")
      end
    end
    Metanorma::Mirror.inline_content_iterator = iterator
    expect(Metanorma::Mirror.inline_content_iterator).to eq(iterator)
  ensure
    Metanorma::Mirror.inline_content_iterator = nil
  end
end
