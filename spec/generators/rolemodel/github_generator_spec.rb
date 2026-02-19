RSpec.describe Rolemodel::GithubGenerator, type: :generator do
  before do
    respond_to_prompt with: 'a' # prompt for overriding ci.yml
    run_generator_against_test_app
  end

  it 'creates github pull request template' do
    assert_file '.github/pull_request_template.md' do |content|
      expect(content).not_to include('Update version number in `lib/rolemodel_rails/version.rb`')
    end
  end

  it 'creates copilot instructions' do
    assert_file '.github/copilot-instructions.md'
    assert_file '.github/instructions/js.instructions.md'
    assert_file '.github/instructions/ruby_model.instructions.md'
    assert_file '.github/instructions/slim.instructions.md'
  end

  it 'creates copilot skills' do
    assert_file '.github/skills/bem-structure/SKILL.md'
    assert_file '.github/skills/controller-patterns/SKILL.md'
    assert_file '.github/skills/dynamic-nested-attributes/SKILL.md'
    assert_file '.github/skills/form-auto-save/SKILL.md'
    assert_file '.github/skills/frontend-patterns/SKILL.md'
    assert_file '.github/skills/json-typed-attributes/SKILL.md'

    assert_file '.github/skills/optics-context/SKILL.md'
    assert_file '.github/skills/optics-context/assets/components.json'
    assert_file '.github/skills/optics-context/assets/tokens.json'

    assert_file '.github/skills/routing-patterns/SKILL.md'
    assert_file '.github/skills/stimulus-controllers/SKILL.md'
    assert_file '.github/skills/testing-patterns/SKILL.md'
    assert_file '.github/skills/theming-context/SKILL.md'
    assert_file '.github/skills/turbo-fetch/SKILL.md'
  end

  it 'creates ci.yml and updates the database.yml' do
    assert_file '.github/workflows/ci.yml' do |content|
      expect(content).to include('Linting & Ruby Non-System Tests')
    end

    assert_file 'config/database.yml' do |content|
      expect(content).to include('  username: <%= ENV.fetch("POSTGRES_USER") %>')
      expect(content).to include('  password: <%= ENV.fetch("POSTGRES_PASSWORD") { nil } %>')
      expect(content).to include('  host: localhost')
    end
  end
end
