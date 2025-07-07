require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'generators/rolemodel/linters/rubocop/templates/lib/cops/form_error_response'

RSpec.describe Cops::FormErrorResponse, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'registers an offense when :unprocessable_entity is absent' do
    expect_offense(<<~RUBY)
      if false
        # redirect_to
      else
        render :new
        ^^^^^^^^^^^ Use status: :unprocessable_entity for invalid form requests.
      end
    RUBY
  end

  it 'does not register an offense when :unprocessable_entity is present' do
    expect_no_offenses(<<~RUBY)
      if false
        # redirect_to
      else
        render :new, status: :unprocessable_entity
      end
    RUBY
  end
end
