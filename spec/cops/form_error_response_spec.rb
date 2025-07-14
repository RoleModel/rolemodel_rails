require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'generators/rolemodel/linters/rubocop/templates/lib/cops/form_error_response'

RSpec.describe Cops::FormErrorResponse, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'registers an offense when :unprocessable_content is absent' do
    expect_offense(<<~RUBY)
      if @user.save
        redirect_to users_url, notice: notice_msg('User successfully updated')
      else
        render :new
        ^^^^^^^^^^^ Use status: :unprocessable_content for invalid form requests.
      end
    RUBY
    expect_correction(<<~RUBY)
      if @user.save
        redirect_to users_url, notice: notice_msg('User successfully updated')
      else
        render :new, status: :unprocessable_content
      end
    RUBY
  end

  it 'does not register an offense when :unprocessable_content is present' do
    expect_no_offenses(<<~RUBY)
      if @user.save
        redirect_to users_url, notice: notice_msg('User successfully updated')
      else
        render :new, status: :unprocessable_content
      end
    RUBY
  end

  describe '.http_status' do
    context 'rack >= 3.1' do
      before do
        allow(described_class).to receive(:rack_version).and_return(Gem::Version.new('3.1'))
      end

      it 'has the correct http_status' do
        expect(described_class.http_status).to eq :unprocessable_content
      end
    end

    context 'rack < 3.1' do
      before do
        allow(described_class).to receive(:rack_version).and_return(Gem::Version.new('3.0'))
      end

      it 'has the correct http_status' do
        expect(described_class.http_status).to eq :unprocessable_entity
      end
    end
  end
end
