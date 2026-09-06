# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Mirror::DefaultRegistry do
  it "builds an empty registry when no hooks are registered" do
    expect(Metanorma::Mirror.build_default_registry)
      .to be_a(Metanorma::Mirror::HandlerRegistry)
  end
end
