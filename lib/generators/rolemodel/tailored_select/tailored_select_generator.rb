# frozen_string_literal: true

module Rolemodel
  class TailoredSelectGenerator < BaseGenerator
    source_root File.expand_path('templates', __dir__)

    def add_tailored_select_package
      say 'Installing Tailored Select package', :green

      run 'yarn add @rolemodel/tailored-select'
    end
  end
end
