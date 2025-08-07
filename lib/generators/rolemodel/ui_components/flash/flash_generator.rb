# frozen_string_literal: true

module Rolemodel
  module UiComponents
    class FlashGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_flash_files
        say 'Copying Flash files', :green

        copy_file 'app/views/layouts/_flash.html.slim'
        copy_file 'spec/support/matchers/flash_matchers.rb'

        insert_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
          optimize_indentation <<~SLIM, 4
            = render 'layouts/flash'
          SLIM
        end
      end
    end
  end
end
