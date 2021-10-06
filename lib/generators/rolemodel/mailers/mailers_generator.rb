require_relative '../../bundler_helpers'


module Rolemodel
  class MailersGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def install_premailer_rails
      gem 'premailer-rails'
      run_bundle
    end

    def add_premailer_rails_config
      copy_file 'config/initializers/premailer_rails.rb'
    end

    def add_action_mailer_asset_host
      unless File.exist?(Rails.root.join('config/initializers/devise.rb'))
        inject_into_file 'config/environments/development.rb', after: "config.action_mailer.perform_caching = false\n" do
          optimize_indentation <<~'RUBY', 2

            # Default mailing host suggested by Devise installation instructions
            config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
          RUBY
        end
      end
      
      inject_into_file 'config/environments/development.rb', after: "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }\n" do
        optimize_indentation <<~'RUBY', 2

          # Ensure premailer_rails can point to webpack compiled resources
          # https://github.com/fphilipe/premailer-rails/issues/232#issuecomment-839819705
          config.action_mailer.asset_host = 'http://localhost:3000'
        RUBY
      end
    end

    def add_mailer_css
      copy_file 'app/javascript/packs/mailer_stylesheets.scss'
    end

    def add_mailer_layout
      copy_file 'app/views/layouts/mailer.html.slim'
    end

    def add_mailer_template_logo
      copy_file 'public/logo.png'
    end

    def add_mailer_template
      copy_file 'app/mailers/user_mailer.rb'
      copy_file 'app/views/user_mailer/welcome_email.html.slim'
      copy_file 'spec/mailers/previews/user_preview.rb'
    end
  end
end
