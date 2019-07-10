module Rolemodel
  class AllGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def run_all_the_generators
      base_path = File.expand_path('.', __dir__)
      Dir.glob(Pathname(base_path).join('*', '*generator.rb')).each do |generator|
        directory_path = generator.sub(base_path, '')
        all_generator = directory_path.match('all_generator')
        if all_generator
          name = File.dirname(generator).split('/').last
          generate "rolemodel:#{name}:all"
        else
          name = File.basename(generator, '_generator.rb')
          generate "rolemodel:#{name}"
        end
      end
    end
  end
end
