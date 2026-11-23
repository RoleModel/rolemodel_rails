RSpec.describe Rolemodel::MailersGenerator, type: :generator do
  # The full generator needs postcss.config.cjs from the webpack generator.
  # These examples run single steps.
  def run_step(name)
    FileUtils.cd(destination_root) do
      capture(:stdout) { described_class.new([], [], destination_root:).public_send(name) }
    end
  end

  before { run_step(:add_production_mailer_defaults) }

  it 'copies the staging interceptor that production.rb requires' do
    assert_file 'app/mailers/staging_mailer_interceptor.rb' do |content|
      expect(content).to include('Rails.configuration.x.whitelisted_emails')
    end
    assert_file 'config/environments/production.rb' do |content|
      expect(content).to start_with("require Rails.root.join('app/mailers/staging_mailer_interceptor')")
    end
  end

  it 'adds the mailer settings inside the configure block' do
    assert_file 'config/environments/production.rb' do |content|
      expect(content).to include('if config.x.whitelisted_emails.any?')
      expect(content).to include('host = config.x.production_host')
      expect(content).to include('password: config.x.sendgrid.api_key,')
      expect(content).to end_with("  }\nend\n")
    end
  end

  it 'reads the settings with EnvValue' do
    assert_file 'config/application.rb' do |content|
      expect(content).to include("config.x.whitelisted_emails = EnvValue.array('WHITELISTED_EMAILS')")
      expect(content).to include("config.x.heroku_app_name = EnvValue.string('HEROKU_APP_NAME')")
      expect(content).to include("config.x.production_host = EnvValue.string('PRODUCTION_HOST')")
      expect(content).to include("config.x.sendgrid.api_key = EnvValue.string('SENDGRID_API_KEY')")
      expect(content).to end_with("EnvValue.string('SENDGRID_API_KEY')\n  end\nend\n")
    end
  end

  it 'adds the asset host for development, and keeps the single localhost default_url_options Rails wrote' do
    run_step(:add_action_mailer_asset_host)

    assert_file 'config/environments/development.rb' do |content|
      expect(content).to end_with("  config.action_mailer.asset_host = 'http://localhost:3000'\nend\n")
      expect(content.scan('config.action_mailer.default_url_options').size).to eq 1
    end
  end
end
