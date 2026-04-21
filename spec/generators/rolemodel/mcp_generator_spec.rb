RSpec.describe Rolemodel::McpGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'adds the MCP controller' do
    assert_file 'app/controllers/mcp_controller.rb' do |content|
      expect(content).to include('Example Rails Current')
      expect(content).to include('example_rails_current')
    end
    assert_file 'spec/requests/mcp_controller_spec.rb'

    assert_file 'app/policies/mcp_policy.rb'
    assert_file 'spec/policies/mcp_policy_spec.rb'

    assert_file 'config/routes.rb' do |content|
      expect(content).to include("match '/mcp', to: 'mcp#handle', via: %i[get post delete]")
    end
    assert_file 'Gemfile' do |content|
      expect(content).to include('gem "mcp"')
    end
  end

  it 'adds sample MCP resource, tool, and prompt' do
    assert_file 'app/mcp/resources/docs/SAMPLE_DOC.md'
    assert_file 'app/mcp/resources/handler.rb'
    assert_file 'spec/mcp/resources/handler_spec.rb'
    assert_file 'app/mcp/resources/docs_handler.rb'
    assert_file 'spec/mcp/resources/docs_handler_spec.rb'
    assert_file 'app/mcp/prompts/sample.rb'
    assert_file 'spec/mcp/prompts/sample_spec.rb'
    assert_file 'app/mcp/tools/sample.rb'
    assert_file 'spec/mcp/tools/sample_spec.rb'
  end

  it 'adds doorkeeper' do
    assert_file 'Gemfile' do |content|
      expect(content).to include('gem "doorkeeper"')
    end
    assert_file 'config/initializers/doorkeeper.rb'
    assert_file 'config/locales/doorkeeper.en.yml'
    assert_file 'app/views/layouts/doorkeeper.html.slim'
    assert_file 'app/views/doorkeeper/authorizations/new.html.slim' do |content|
      expect(content).to include('Example Rails Current - Authorize Application')
    end
    assert_file 'app/views/doorkeeper/authorizations/error.html.slim' do |content|
      expect(content).to include('Example Rails Current - Error Authorizing Application')
    end
    assert_file 'app/controllers/doorkeeper/base_controller.rb'
    assert_file 'app/assets/stylesheets/components/doorkeeper.css'

    assert_file 'config/routes.rb' do |content|
      expect(content).to include('use_doorkeeper')
    end
    assert_file 'app/assets/stylesheets/application.css' do |content|
      expect(content).to include("@import 'components/doorkeeper.css';")
    end
  end

  it 'adds the dynamic registration controller' do
    assert_file 'app/controllers/oauth_registrations_controller.rb'
    assert_file 'spec/requests/oauth_registrations_controller_spec.rb'

    assert_file 'config/routes.rb' do |content|
      expect(content).to include("post '/oauth/register', to: 'oauth_registrations#create'")
    end
  end

  it 'adds the well-known route' do
    assert_file 'app/controllers/well_known_controller.rb'
    assert_file 'spec/requests/well_known_controller_spec.rb'

    assert_file 'config/routes.rb' do |content|
      expect(content).to include("get '/.well-known/oauth-protected-resource', to: 'well_known#oauth_protected_resource'")
      expect(content).to include("get '/.well-known/oauth-authorization-server', to: 'well_known#oauth_authorization_server'")
    end
  end

  it 'updates inflections' do
    assert_file 'config/initializers/inflections.rb' do |content|
      expect(content).to include("\nActiveSupport::Inflector.inflections(:en) do |inflect|")
      expect(content).to include("  inflect.acronym 'MCP'")
    end
  end
end
