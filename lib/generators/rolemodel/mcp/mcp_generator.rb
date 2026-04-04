# frozen_string_literal: true

module Rolemodel
  class MCPGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def update_inflections
      inflections_path = File.join(destination_root, 'config/initializers/inflections.rb')
      block_start = "\nActiveSupport::Inflector.inflections(:en) do |inflect|\n"

      return if File.read(inflections_path).include?("inflect.acronym 'MCP'")

      if File.read(inflections_path).include?(block_start)
        inject_into_file inflections_path, "  inflect.acronym 'MCP'\n", after: block_start
      else
        append_to_file inflections_path, <<~RUBY

          ActiveSupport::Inflector.inflections(:en) do |inflect|
            inflect.acronym 'MCP'
          end
        RUBY
      end
    end

    def install_mcp
      bundle_command 'add mcp'
      template 'app/controllers/mcp_controller.rb'
      copy_file 'spec/requests/mcp_controller_spec.rb'

      route <<~RUBY
        match '/mcp', to: 'mcp#handle', via: %i[get post delete]
      RUBY
    end

    def add_sample_mcp_resource
      copy_file 'app/mcp/resources/controller.rb'
      copy_file 'spec/mcp/resources/controller_spec.rb'

      copy_file 'app/mcp/resources/docs/SAMPLE_DOC.md'
      copy_file 'app/mcp/resources/docs_controller.rb'
      copy_file 'spec/mcp/resources/docs_controller_spec.rb'
    end

    def add_sample_mcp_prompt
      copy_file 'app/mcp/prompts/sample.rb'
      copy_file 'spec/mcp/prompts/sample_spec.rb'
    end

    def add_sample_mcp_tool
      copy_file 'app/mcp/tools/sample.rb'
      copy_file 'spec/mcp/tools/sample_spec.rb'
    end

    def install_doorkeeper
      bundle_command 'add doorkeeper'
      generate 'doorkeeper:install'
    end

    def configure_doorkeeper
      copy_file 'config/initializers/doorkeeper.rb', force: true
      copy_file 'app/controllers/doorkeeper/base_controller.rb'

      copy_file 'app/views/layouts/doorkeeper.html.slim'
      template 'app/views/doorkeeper/authorizations/new.html.slim'
      template 'app/views/doorkeeper/authorizations/error.html.slim'

      copy_file 'app/assets/stylesheets/components/doorkeeper.css'

      route 'use_doorkeeper'
    end

    def apply_doorkeeper_css
      css_manifest = if File.exist?(File.join(destination_root, 'app/assets/stylesheets/application.scss'))
        'app/assets/stylesheets/application.scss'
      else
        'app/assets/stylesheets/application.css'
      end

      return if File.read(File.join(destination_root, css_manifest)).include?("@import 'components/doorkeeper.css';")

      append_to_file css_manifest, <<~CSS
        @import 'components/doorkeeper.css';
      CSS
    end

    def add_oauth_dynamic_registrations
      copy_file 'app/controllers/oauth_registrations_controller.rb'
      copy_file 'spec/requests/oauth_registrations_controller_spec.rb'
      route <<~RUBY
        post '/oauth/register', to: 'oauth_registrations#create'
      RUBY
    end

    def add_well_known_route
      copy_file 'app/controllers/well_known_controller.rb'
      copy_file 'spec/requests/well_known_controller_spec.rb'
      route <<~RUBY
        get '/.well-known/oauth-protected-resource', to: 'well_known#oauth_protected_resource'
        get '/.well-known/oauth-authorization-server', to: 'well_known#oauth_authorization_server'
      RUBY
    end

    private

    def application_name
      Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
    end
  end
end
