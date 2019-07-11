Dir[Rails.root.join('spec', 'support', 'helpers', '**', '*.rb')].each { |f| require f }

# this is a place to pull in all your app specific DSL methods.

RSpec.configure do |c|
  # for example, given you have a spec/support/helpers/login_helpers.rb
  # c.include LoginHelpers, type: :system
end
