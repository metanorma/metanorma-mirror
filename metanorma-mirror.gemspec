# frozen_string_literal: true

require_relative "lib/metanorma/mirror/version"

Gem::Specification.new do |spec|
  spec.name = "metanorma-mirror"
  spec.version = Metanorma::Mirror::VERSION
  spec.authors = ["Ribose Inc."]
  spec.email = ["open.source@ribose.com"]

  spec.summary = "Metanorma Mirror — the lossless JSON projection of Metanorma documents"
  spec.description = "A typed node tree (blocks, inlines, marks) projected from Metanorma " \
                     "document models, with serializers and an output pipeline. " \
                     "metanorma-document and metanorma-standoc register their model " \
                     "classes; the format is the wire contract for renderers and " \
                     "tooling (the SMART document reader, the HTML JS renderer)."
  spec.homepage = "https://github.com/metanorma/metanorma-mirror"
  spec.license = "BSD-2-Clause"

  spec.files = Dir["lib/**/*.rb"] + %w[README.adoc LICENSE]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lutaml-model", "~> 0.8"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1"
  spec.add_development_dependency "rubocop-performance", "~> 1"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec", "~> 3"
end
