module Rolemodel
  module Testing
    class AllGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        Dir.glob(Pathname(File.expand_path('.', __dir__)).join('*', '*generator.rb')).each do |generator|
          name = File.basename(generator, '_generator.rb')
          generate "rolemodel:testing:#{name}"
        end
      end
    end
  end
end
