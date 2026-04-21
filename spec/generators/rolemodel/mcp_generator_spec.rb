RSpec.describe Rolemodel::McpGenerator, type: :generator do
  let(:policy_choice) { 'pundit' }
  let(:devise_choice) { 'yes' }

  before do
    respond_to_prompt with: policy_choice
    respond_to_prompt with: devise_choice
    run_generator_against_test_app
  end

  # They're all in a single test because the MCP generator takes so long to run.
  it 'adds the MCP controller and all related resources' do # rubocop:disable Metrics/BlockLength
    assert_file 'app/controllers/mcp_controller.rb' do |content|
      expect(content).to include('skip_before_action :authenticate_user!')
      expect(content).not_to include('rescue_from ActionPolicy::Unauthorized, with: :unauthorized_request')
      expect(content).to include('rescue_from Pundit::NotAuthorizedError, with: :unauthorized_request')
      expect(content).to include('Example Rails Current')
      expect(content).to include('example_rails_current')
    end
    assert_file 'spec/requests/mcp_controller_spec.rb'

    assert_file 'app/policies/mcp_policy.rb'
    assert_file 'spec/policies/mcp_policy_spec.rb' do |content|
      expect(content).not_to include('describe_rule :handle?')
      expect(content).to include('permissions :handle?')
    end

    assert_file 'config/routes.rb' do |content|
      expect(content).to include("match '/mcp', to: 'mcp#handle', via: %i[get post delete]")
    end
    assert_file 'Gemfile' do |content|
      expect(content).to include('gem "mcp"')
    end

    # sample MCP resource, tool, and prompt
    assert_file 'app/mcp/resources/docs/SAMPLE_DOC.md'
    assert_file 'app/mcp/resources/handler.rb'
    assert_file 'spec/mcp/resources/handler_spec.rb'
    assert_file 'app/mcp/resources/docs_handler.rb'
    assert_file 'spec/mcp/resources/docs_handler_spec.rb'
    assert_file 'app/mcp/prompts/sample.rb'
    assert_file 'spec/mcp/prompts/sample_spec.rb'
    assert_file 'app/mcp/tools/sample.rb'
    assert_file 'spec/mcp/tools/sample_spec.rb'

    # Doorkeeper
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

    # dynamic registration controller
    assert_file 'app/controllers/oauth_registrations_controller.rb' do |content|
      expect(content).to include('skip_before_action :authenticate_user!')
      expect(content).to include('skip_after_action :verify_authorized')
      expect(content).not_to include('skip_verify_authorized')
    end
    assert_file 'spec/requests/oauth_registrations_controller_spec.rb'

    assert_file 'config/routes.rb' do |content|
      expect(content).to include("post '/oauth/register', to: 'oauth_registrations#create'")
    end

    # well-known route
    assert_file 'app/controllers/well_known_controller.rb' do |content|
      expect(content).to include('skip_before_action :authenticate_user!')
      expect(content).to include('skip_after_action :verify_authorized')
      expect(content).not_to include('skip_verify_authorized')
    end
    assert_file 'spec/requests/well_known_controller_spec.rb'

    assert_file 'config/routes.rb' do |content|
      expect(content).to include("get '/.well-known/oauth-protected-resource', to: 'well_known#oauth_protected_resource'")
      expect(content).to include("get '/.well-known/oauth-authorization-server', to: 'well_known#oauth_authorization_server'")
    end

    # Inflections
    assert_file 'config/initializers/inflections.rb' do |content|
      expect(content).to include("\nActiveSupport::Inflector.inflections(:en) do |inflect|")
      expect(content).to include("  inflect.acronym 'MCP'")
    end
  end

  context 'without Devise' do
    let(:devise_choice) { 'no' }

    it 'adds the controllers without Devise-specific code' do
      assert_file 'app/controllers/mcp_controller.rb' do |content|
        expect(content).not_to include('skip_before_action :authenticate_user!')
      end
      assert_file 'app/controllers/oauth_registrations_controller.rb' do |content|
        expect(content).not_to include('skip_before_action :authenticate_user!')
      end
      assert_file 'app/controllers/well_known_controller.rb' do |content|
        expect(content).not_to include('skip_before_action :authenticate_user!')
      end
    end
  end

  context 'with Action Policy' do
    let(:policy_choice) { 'action_policy' }

    it 'generates Action Policy policies' do
      assert_file 'app/controllers/mcp_controller.rb' do |content|
        expect(content).to include('rescue_from ActionPolicy::Unauthorized, with: :unauthorized_request')
        expect(content).not_to include('rescue_from Pundit::NotAuthorizedError, with: :unauthorized_request')
      end

      assert_file 'app/controllers/oauth_registrations_controller.rb' do |content|
        expect(content).to include('skip_before_action :authenticate_user!')
        expect(content).not_to include('skip_after_action :verify_authorized')
        expect(content).to include('skip_verify_authorized')
      end

      assert_file 'app/controllers/well_known_controller.rb' do |content|
        expect(content).to include('skip_before_action :authenticate_user!')
        expect(content).not_to include('skip_after_action :verify_authorized')
        expect(content).to include('skip_verify_authorized')
      end

      assert_file 'spec/policies/mcp_policy_spec.rb' do |content|
        expect(content).to include('describe_rule :handle?')
        expect(content).not_to include('permissions :handle?')
      end
    end
  end
end
