# frozen_string_literal: true

require 'open3'

load File.expand_path('../../bin/bump_version', __dir__)

RSpec.describe VersionBumper do
  after do
    ENV.delete('BUMP_VERSION_AUTOMATED')
  end

  describe 'automated-environment guard' do
    it 'raises before bumping anything when BUMP_VERSION_AUTOMATED is not set' do
      ENV.delete('BUMP_VERSION_AUTOMATED')

      expect { described_class.new([], {}).invoke_all }.to raise_error(Thor::InvocationError, /GitHub Actions workflow/)
    end

    it 'raises when BUMP_VERSION_AUTOMATED is set to a non-true value' do
      ENV['BUMP_VERSION_AUTOMATED'] = 'false'

      expect { described_class.new([], {}).invoke_all }.to raise_error(Thor::InvocationError)
    end
  end

  describe 'process exit status' do
    it 'exits non-zero with the guard message, and leaves the version file untouched' do
      env = ENV.to_h.merge('BUMP_VERSION_AUTOMATED' => nil)
      version_before = File.read('lib/rolemodel/version.rb')

      _stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, File.expand_path('../../bin/bump_version', __dir__))

      expect(status).not_to be_success
      expect(stderr).to include('GitHub Actions workflow')
      expect(File.read('lib/rolemodel/version.rb')).to eq(version_before)
    end
  end
end
