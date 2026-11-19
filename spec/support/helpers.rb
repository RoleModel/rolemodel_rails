# frozen_string_literal: true

Dir[File.expand_path('spec/support/helpers/**/*.rb', Dir.pwd)].each { require it }

RSpec.configure do |c|
  c.include ExampleApp
  c.include RespondToPrompt
  c.include SkillsCliStub
  # Only the dotenv spec needs a real `bundle add dotenv`. Other generators invoke rolemodel:dotenv
  # through add_setting, and running bundler there would slow every example.
  c.before(type: :generator) do
    next if described_class == Rolemodel::DotenvGenerator

    allow_any_instance_of(Rolemodel::DotenvGenerator).to receive(:install_dotenv)
  end
  c.around(type: :generator) do |example|
    original = ENV.to_h.slice('PATH', 'XDG_STATE_HOME')
    stub_skills_cli
    example.run
  ensure
    ENV.update(original)
    ENV.delete('XDG_STATE_HOME') unless original.key?('XDG_STATE_HOME')
  end
end
