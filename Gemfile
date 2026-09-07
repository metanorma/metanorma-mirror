# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# A format gem: runtime is lutaml-model only. Model knowledge lives in
# the model gems (metanorma-document, metanorma-standoc), which register
# their classes through the seams in Metanorma::Mirror; the full-stack
# integration suites live in those repos.
#
# Dependency sources. Default (no env vars): released gems, exactly the
# contract downstream users get. METANORMA_CI_EDGE=1 tracks upstream
# main branches.
if ENV["METANORMA_CI_EDGE"]
  gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
else
  gem "leptris", "~> 1.9"
  gem "lutaml-model", "~> 0.8.0", ">= 0.8.22", "< 0.9"
  gem "moxml", "~> 0.5.30"
end
