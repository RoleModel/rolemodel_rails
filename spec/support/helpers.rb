# frozen_string_literal: true

Dir[File.expand_path('spec/support/helpers/**/*.rb', Dir.pwd)].each { require it }

RSpec.configure do |c|
  c.include ExampleApp
  c.include RespondToPrompt
end
