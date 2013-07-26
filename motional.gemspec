# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motional/version'

Gem::Specification.new do |spec|
  spec.name          = "motional"
  spec.version       = MotionAL::VERSION
  spec.authors       = ["akahigeg"]
  spec.email         = ["akahigeg@gmail.com"]
  spec.description   = %q{AssetLibrary framework wrapper for RubyMotion}
  spec.summary       = %q{AssetLibrary framework wrapper for RubyMotion}
  spec.homepage      = "https://github.com/akahigeg/motional"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "motion-redgreen"
  spec.add_development_dependency "awesome_print_motion"
end
