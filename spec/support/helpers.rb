# frozen_string_literal: true

Dir[File.expand_path('spec/support/helpers/**/*.rb', Dir.pwd)].each { require it }

RSpec.configure do |c|
  c.include ExampleApp
  c.include RespondToPrompt
  c.include SkillsCliStub
  c.around(type: :generator) do |example|
    original = ENV.to_h.slice('PATH', 'XDG_STATE_HOME')
    stub_skills_cli
    example.run
  ensure
    ENV.update(original)
    ENV.delete('XDG_STATE_HOME') unless original.key?('XDG_STATE_HOME')
  end
end
