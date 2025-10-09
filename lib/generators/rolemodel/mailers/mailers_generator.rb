# frozen_string_literal: true

module Rolemodel
  class MailersGenerator < Rails::Generators::Base
    include BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def install_premailer_rails
      run 'bundle add premailer-rails'
    end

    def add_premailer_rails_config
      copy_file 'config/initializers/premailer_rails.rb'
    end

    def include_postcss_calc
      inject_into_file 'postcss.config.cjs', ",\n    require('postcss-calc')", after: /^\s*require\('postcss-preset-env'\)\({(.|\n)*?}\)/
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

    def add_production_mailer_defaults
      prepend_to_file 'config/environments/production.rb', "require Rails.root.join('app/mailers/staging_mailer_interceptor')\n"

      inject_into_file 'config/environments/production.rb', after: "config.action_mailer.perform_caching = false\n" do
        optimize_indentation <<~'RUBY', 2
          # Prevent live user emails from being sent out in staging
          if ENV['WHITELISTED_EMAILS'].present?
            ActionMailer::Base.register_interceptor(StagingMailerInterceptor)
          end

          host = ENV['PRODUCTION_HOST']

          # Ensure premailer_rails can point to webpack compiled resources
          # https://github.com/fphilipe/premailer-rails/issues/232#issuecomment-839819705
          config.action_mailer.asset_host = host

          config.action_mailer.default_url_options = { host: host }
          config.action_mailer.delivery_method = :smtp
          config.action_mailer.perform_deliveries = true
          config.action_mailer.smtp_settings = {
            user_name: 'apikey',
            password: ENV['SENDGRID_API_KEY'],
            domain: host,
            address: 'smtp.sendgrid.net',
            port: 587,
            authentication: :plain,
            enable_starttls_auto: true
          }
        RUBY
      end
    end

    def add_mailer_css
      copy_file 'app/assets/stylesheets/mailer.scss'
    end

    def add_mailer_layout
      copy_file 'app/views/layouts/mailer.html.slim'
    end

    def add_mailer_template_logo
      copy_file 'public/logo.png'
    end

    def remove_default_mailer_template
      remove_file 'app/views/layouts/mailer.html.erb'
      remove_file 'app/views/layouts/mailer.text.erb'
    end

    def add_mailer_template
      copy_file 'app/mailers/example_mailer.rb'
      copy_file 'app/views/example_mailer/example_email.html.slim'
      copy_file 'spec/mailers/previews/example_mailer_preview.rb'
    end
  end
end
