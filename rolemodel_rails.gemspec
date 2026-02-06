# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rolemodel_rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'rolemodel_rails'
  spec.version       = RolemodelRails::VERSION
  spec.authors       = ['RoleModel Software Inc']
  spec.email         = ['it-support@rolemodelsoftware.com']

  spec.summary       = 'Rails generators for RoleModel Software project setup.'
  spec.description   = 'A collection of Rails generators to set up a Rails project with the recommended configuration for RoleModel Software projects.'
  spec.homepage      = 'https://github.com/RoleModel/rolemodel_rails'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|example)/})
  end

  spec.required_ruby_version = '>= 3.4'

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '> 7.1'

  spec.add_development_dependency 'bundler', '~> 4'
  spec.add_development_dependency 'generator_spec', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'benchmark'
end
