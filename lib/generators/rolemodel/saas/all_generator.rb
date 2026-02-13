module Rolemodel
  module Saas
    class AllGenerator < BaseGenerator
      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        # no guaranteed order to this list with Dir.glob
        Dir.glob(Pathname(File.expand_path('.', __dir__)).join('*', '*generator.rb')).each do |generator|
          name = File.basename(generator, '_generator.rb')
          generate "rolemodel:saas:#{name}"
        end
      end
    end
  end
end
