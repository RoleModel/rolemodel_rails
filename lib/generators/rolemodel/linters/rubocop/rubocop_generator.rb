# frozen_string_literal: true

module Rolemodel
  module Linters
    # Install the standard rubocop and a custom cop
    class RubocopGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def install_rubocop
        gem_group :development, :test do
          gem 'rubocop'
          gem 'rubocop-rails'
        end
        run_bundle
      end

      def add_config
        copy_file '.rubocop.yml', force: true
        # Custom cops live in .rubocop/cops (loaded via .rubocop.yml's require:),
        # not lib/cops — keeping them out of Rails' autoload/eager-load paths so
        # they don't crash production boot referencing the dev/test-only RuboCop
        # constant.
        directory '.rubocop/cops'
      end
    end
  end
end
