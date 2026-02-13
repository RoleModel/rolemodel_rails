require 'rails'
require 'pathname'
require 'rails/generators/bundle_helper'
require_relative 'rolemodel/replace_content_helper'

module Rolemodel
  RUBY_VERSION = Pathname.pwd.join('.ruby-version').read.strip
  NODE_VERSION = Pathname.pwd.join('.node-version').read.strip

  class ApplicationGenerator < Rails::Generators::Base
    include Rails::Generators::BundleHelper
    include ReplaceContentHelper

  private
    # based on https://github.com/rails/rails/blob/main/railties/lib/rails/generators/app_base.rb#L713
    def run_bundle
      bundle_command("install --quiet", "BUNDLE_IGNORE_MESSAGES" => "1")
    end
  end

  Dir['lib/generators/rolemodel/**/*.rb'].each do |file|
    load file if file.end_with?('_generator.rb')
  end
end
