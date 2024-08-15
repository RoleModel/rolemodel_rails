# frozen_string_literal: true

Dir[File.expand_path('spec/support/helpers/**/*.rb', Dir.pwd)].each { |f| require f }

RSpec.configure do |c|
  c.include ExampleApp
end
