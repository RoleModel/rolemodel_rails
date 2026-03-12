RSpec.describe Rolemodel::GithubGenerator, type: :generator do
  let(:command_options) { [] }
  let(:tags_fixture) do
    <<~TAGS
      cc20cd16985dd6a9813c9ac5119f5a78fd1565b8	refs/tags/alpha
      fd68a550dacfe7572ff3d39eb9d189c8ca574291	refs/tags/v1
      6fe5aeacb732eeef6f911ff63046ea32d92ed1fa	refs/tags/v2
      aaa60fc63890e435638ce3d5e0499c9a9f94a535	refs/tags/v3.2.1
      4e68af3f56ef4a26f3e8a4f377f8beed62668392	refs/tags/v4
      f52c7352fef417c4e4799b45b0f73fea7a10c1d0	refs/tags/v5
    TAGS
  end

  before do
    allow_any_instance_of(described_class).to receive(:`).and_return(tags_fixture)
    run_generator_against_test_app(command_options)
  end

  describe 'provided the --no-playwright option' do
    let(:command_options) { ['--no-playwright'] }

    it 'sets webdriver to selenium in ci.yml' do
      assert_file '.github/workflows/ci.yml' do |content|
        expect(content).to include('web-driver: selenium')
      end
    end
  end

  it 'creates github pull request template' do
    assert_file '.github/pull_request_template.md' do |content|
      expect(content).not_to include('Update version number in `lib/rolemodel_rails/version.rb`')
    end

    assert_file '.github/instructions/css.instructions.md'
    assert_file '.github/instructions/js.instructions.md'
    assert_file '.github/instructions/project.instructions.md'
    assert_file '.github/instructions/ruby.instructions.md'
    assert_file '.github/instructions/slim.instructions.md'
  end

  it 'creates ci.yml and updates the database.yml' do
    assert_file '.github/workflows/ci.yml' do |content|
      expect(content).to include('Linting & Ruby Non-System Tests')
      expect(content).to include('RoleModel/actions/linting-and-non-system-tests@v5')
      expect(content).to include('web-driver: playwright')
    end

    assert_file 'config/database.yml' do |content|
      expect(content).to include('  username: <%= ENV.fetch("POSTGRES_USER") %>')
      expect(content).to include('  password: <%= ENV.fetch("POSTGRES_PASSWORD") { nil } %>')
      expect(content).to include('  host: localhost')
    end
  end

  it 'creates dependabot.yml' do
    assert_file '.github/dependabot.yml' do |content|
      expect(content).to include('version: 2')
      expect(content).to include('package-ecosystem: bundler')
      expect(content).to include('directory: /')
      expect(content).to include('schedule:')
      expect(content).to include('interval: weekly')
      expect(content).to include('day: monday')
    end
  end

  it 'creates CODEOWNERS' do
    assert_file '.github/CODEOWNERS' do |content|
      expect(content).to include('# Dependabot / Dependency reviewers:')
      expect(content).to include('# yarn.lock')
      expect(content).to include('# Gemfile.lock')
    end
  end
end
