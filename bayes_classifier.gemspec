# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bayes_classifier/version'

Gem::Specification.new do |spec|
  spec.name          = "bayes_classifier"
  spec.version       = Bayes::VERSION
  spec.authors       = ["DarthSim"]
  spec.email         = ["darthsim@gmail.com"]
  spec.description   = "Naive Bayes classifier"
  spec.summary       = "Allows to classify strings with naive Bayes classifier"
  spec.homepage      = "https://github.com/DarthSim/bayes_classifier"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fuubar"
end
