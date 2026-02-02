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
  spec.description   = 'Rails generators for RoleModel Software project setup.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  # TODO: Why don't we publish this??
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|example)/})
  end
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
