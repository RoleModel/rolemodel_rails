# frozen_string_literal: true

module Rolemodel
  module UiComponents
    class FlashGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def generate_files
        say 'generating flash message partial & spec helper', :green

        copy_file 'app/views/application/_flash.html.slim'
        copy_file 'spec/support/matchers/flash_matchers.rb'

        insert_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
          optimize_indentation <<~SLIM, 4
            = render 'flash'
          SLIM
        end
      end
    end
  end
end
