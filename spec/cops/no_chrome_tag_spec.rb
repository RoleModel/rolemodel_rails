require 'spec_helper'
require 'generators/rolemodel/linters/rubocop/templates/lib/cops/no_chrome_tag'
require 'rubocop'
require 'rubocop/rspec/support'

RSpec.describe Cops::NoChromeTag, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'registers an offense when :chrome is present' do
    expect_offense(<<~RUBY)
      it 'expects things', :chrome
                         ^^^^^^^^^ The :chrome tag is only for testing, and should not be checked into the repository.
    RUBY
    expect_correction(%(it 'expects things'\n))
  end

  it 'registers an offense when chrome: true is present' do
    expect_offense(<<~RUBY)
      it 'expects things', chrome: true
                         ^^^^^^^^^^^^^^ The :chrome tag is only for testing, and should not be checked into the repository.
    RUBY
    expect_correction(%(it 'expects things'\n))
  end

  it 'registers an offense when chrome: true is present with other values' do
    expect_offense(<<~RUBY)
      it 'expects things', chrome: true, other: false
                         ^^^^^^^^^^^^^^ The :chrome tag is only for testing, and should not be checked into the repository.
    RUBY
    expect_correction(%(it 'expects things', other: false\n))
  end

  it 'registers an offense when :chrome is present and chrome: true is present' do
    expect_offense(<<~RUBY)
      it 'expects things', :chrome, chrome: true
                                  ^^^^^^^^^^^^^^ The :chrome tag is only for testing, and should not be checked into the repository.
                         ^^^^^^^^^ The :chrome tag is only for testing, and should not be checked into the repository.
    RUBY
    expect_correction(%(it 'expects things'\n))
  end

  it 'does not register an offense when chrome: is not present' do
    expect_no_offenses(<<~RUBY)
      it 'expects things', :js
    RUBY
  end
end
