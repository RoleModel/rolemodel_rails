module Rolemodel
  class SoftDestroyableGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def add_concern
      copy_file 'soft_destroyable.rb', 'app/models/concerns/soft_destroyable.rb'
    end

    def add_shared_example
      copy_file 'soft_destroyable_behavior.rb', 'spec/support/shared_examples/soft_destroyable_behavior.rb'
    end
  end
end
