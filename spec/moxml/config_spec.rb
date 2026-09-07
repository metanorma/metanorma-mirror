# frozen_string_literal: true

require "spec_helper"

# The dev bundle owns leptris so local suites run the fast backend
# (the metanorma-document convention): assert the adapter engages, so
# a resolution that silently falls back to nokogiri is caught here,
# not as a performance regression downstream.
RSpec.describe Moxml::Config do
  it "engages leptris when the gem is in the resolution" do
    skip "not in this resolution" unless Gem.loaded_specs.key?("leptris")

    require "moxml"
    expect(described_class.default_adapter).to eq(:leptris)
  end
end
