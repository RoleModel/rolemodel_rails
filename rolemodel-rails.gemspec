require_relative 'lib/rolemodel/version'

Gem::Specification.new do |spec|
  spec.name          = 'rolemodel-rails'
  spec.version       = Rolemodel::VERSION
  spec.authors       = ['RoleModel Software Inc']
  spec.email         = ['it-support@rolemodelsoftware.com']

  spec.summary       = 'The RoleModel Way of building Rails apps.'
  spec.description   = 'A collection of executable best practices for common aspects of Rails application development.'
  spec.homepage      = 'https://github.com/RoleModel/rolemodel_rails'
  spec.license       = 'MIT'

  spec.files = Dir['{app,lib}/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']

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
  spec.add_development_dependency 'doorkeeper'
end
