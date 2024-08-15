
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rolemodel_rails/version"

Gem::Specification.new do |spec|
  spec.name          = "rolemodel_rails"
  spec.version       = RolemodelRails::VERSION
  spec.authors       = ["RoleModel Software Inc"]
  spec.email         = ["it-support@rolemodelsoftware.com"]

  spec.summary       = %q{Rails generator for RoleModel Software Rails initial project setup.}
  spec.description   = %q{Rails generator for RoleModel Software Rails initial project setup.}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|example|example_with_webpacker)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "rubocop"
end
