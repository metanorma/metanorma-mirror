# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Mirror::ClassTable do
  let(:base) { Class.new }
  let(:derived) { Class.new(base) }
  let(:unrelated) { Class.new }

  it "looks up by exact class" do
    table = described_class.new
    table.register(base, :payload)
    expect(table.lookup(base.new)).to be(:payload)
  end

  it "falls back to ancestors in registration-independent order" do
    table = described_class.new
    table.register(base, :payload)
    expect(table.lookup(derived.new)).to be(:payload)
  end

  it "prefers the nearest registered ancestor" do
    middle = Class.new(base)
    table = described_class.new
    table.register(base, :far)
    table.register(middle, :near)
    klass = Class.new(middle)
    expect(table.lookup(klass.new)).to be(:near)
  end

  it "returns nil for unregistered classes" do
    table = described_class.new
    table.register(base, :payload)
    expect(table.lookup(unrelated.new)).to be_nil
  end

  it "reports registered? and empty?" do
    table = described_class.new
    expect(table).to be_empty
    expect(table).not_to be_registered(base)
    table.register(base, :payload)
    expect(table).not_to be_empty
    expect(table).to be_registered(base)
  end
end
