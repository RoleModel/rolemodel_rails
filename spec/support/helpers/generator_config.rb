# frozen_string_literal: true

require 'rails/configuration'

# Helpers for specs that exercise the generator registry's read path:
# Rails::Generators.options populated from a consuming app's config.generators.
#
# Rails::Generators memoizes that state process-globally and configure!
# deep-merges into it, so any example that touches it must run under the
# :generator_config metadata, which snapshots and restores the state around
# the example. Without it, configured keys leak into later examples and
# registry-dependent specs become order-dependent.
module GeneratorConfig
  GENERATOR_STATE = %i[
    @options @aliases @fallbacks @templates_path @hidden_namespaces @after_generate_callbacks
  ].freeze

  # Applies config the same way a consuming app's `config.generators` block
  # does: through Rails::Configuration::Generators and Rails::Generators.configure!.
  def apply_generator_config
    config = Rails::Configuration::Generators.new
    yield config
    Rails::Generators.configure!(config)
  end

  # Removes generator classes defined inside an example: deregisters them from
  # Rails::Generators.subclasses (the namespace lookup index) and drops the constant.
  def remove_generators(*klasses)
    klasses.each do |klass|
      Rails::Generators.subclasses.delete(klass)
      parts = klass.name.split('::')
      const = parts.pop
      mod = parts.empty? ? Object : Object.const_get(parts.join('::'))
      mod.send(:remove_const, const) if mod.const_defined?(const, false)
    end
  end

  def quietly
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end
end

RSpec.configure do |config|
  config.include GeneratorConfig

  config.around(:each, :generator_config) do |example|
    saved = GeneratorConfig::GENERATOR_STATE.to_h do |ivar|
      [ivar, Rails::Generators.instance_variable_get(ivar).deep_dup]
    end
    example.run
  ensure
    saved.each { |ivar, value| Rails::Generators.instance_variable_set(ivar, value) }
  end
end
