# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vx/common/version'

Gem::Specification.new do |spec|
  spec.name          = "vx-common"
  spec.version       = Vx::Common::VERSION
  spec.authors       = ["Dmitry Galinsky"]
  spec.email         = ["dima.exe@gmail.com"]
  spec.description   = %q{ Common code for ci }
  spec.summary       = %q{ Common code for ci }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'vx-common-spawn', '> 0.0.7'
  spec.add_runtime_dependency 'vx-common-rack-builder', '0.0.2'
  spec.add_runtime_dependency 'airbrake', '~> 4.1.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", '~> 3.1'
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rake"

  # spec.add_development_dependency "vx-message", '0.6.2'
end
