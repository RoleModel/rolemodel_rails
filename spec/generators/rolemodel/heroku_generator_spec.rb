RSpec.describe Rolemodel::HerokuGenerator, type: :generator do
  before { @output = run_generators }

  it 'generates app.json' do
    assert_file 'app.json' do |content|
      expect(content).to include('"name": "ExampleRailsCurrent"')
    end
  end

  it 'generates Procfile' do
    assert_file 'Procfile'
  end

  it 'reads the log level from the "LOG_LEVEL" environment variable' do
    assert_file 'config/application.rb' do |content|
      expect(content).to include("config.x.log_level = EnvValue.string('LOG_LEVEL', default: 'INFO')")
    end
    assert_file 'config/environments/production.rb' do |content|
      expect(content).to include('config.log_level = config.x.log_level')
    end
  end

  it 'creates assets.rake task to remove node_modules directory during production build' do
    assert_file 'lib/tasks/assets.rake'
  end

  it 'prints the path to the deploy-app skill instead of copying it into the repo' do
    expect(@output.values.join).to include('deploy-app/SKILL.md')
    assert_no_file 'AGENTS.md'
    assert_no_file '.claude/skills/deploy-app/SKILL.md'
  end
end
