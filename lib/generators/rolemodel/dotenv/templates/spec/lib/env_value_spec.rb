# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnvValue do
  let(:key) { 'ENV_VALUE_SPEC' }

  around do |example|
    original = ENV.fetch(key, nil)
    example.run
  ensure
    ENV[key] = original
  end

  def in_environment(name)
    allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new(name))
  end

  describe '.string' do
    it 'reads the value' do
      ENV[key] = 'https://example.test'

      expect(described_class.string(key, default: 'fallback')).to eq 'https://example.test'
    end

    it 'falls back to the default when the key is missing or blank' do
      ENV[key] = nil
      expect(described_class.string(key, default: 'fallback')).to eq 'fallback'

      ENV[key] = ' '
      expect(described_class.string(key, default: 'fallback')).to eq 'fallback'
    end

    it 'computes the default from a block only when it is needed' do
      ENV[key] = 'set'
      expect(described_class.string(key) { raise 'should not run' }).to eq 'set'

      ENV[key] = nil
      expect(described_class.string(key) { 'computed' }).to eq 'computed'
    end

    it 'is nil without a value or a default' do
      ENV[key] = nil

      expect(described_class.string(key)).to be_nil
    end
  end

  describe '.string!' do
    it 'reads the value' do
      ENV[key] = '2026-09-01'

      expect(described_class.string!(key)).to eq '2026-09-01'
    end

    it 'raises KeyError when the key is missing, as ENV.fetch does' do
      ENV[key] = nil

      expect { described_class.string!(key) }.to raise_error(KeyError, /ENV_VALUE_SPEC/)
    end

    it 'raises ArgumentError, naming the key, when the value is blank' do
      ENV[key] = ' '

      expect { described_class.string!(key) }.to raise_error(ArgumentError, 'ENV_VALUE_SPEC is blank')
    end
  end

  describe '.url' do
    it 'reads a full URL' do
      ENV[key] = 'https://example.test'

      expect(described_class.url(key)).to eq 'https://example.test'
    end

    it 'checks a default the same way' do
      ENV[key] = nil

      expect(described_class.url(key) { 'http://localhost:3000' }).to eq 'http://localhost:3000'
      expect { described_class.url(key, default: 'localhost:3000') }.to raise_error(ArgumentError)
    end

    it 'rejects a value without a scheme, naming the key' do
      ENV[key] = 'example.test'

      expect { described_class.url(key) }.to raise_error(ArgumentError, /ENV_VALUE_SPEC must be a full URL/)
    end

    it 'is nil without a value or a default' do
      ENV[key] = nil

      expect(described_class.url(key)).to be_nil
    end
  end

  describe 'defaults per environment' do
    before { ENV[key] = nil }

    it 'uses the default named for the current environment' do
      in_environment('staging')

      expect(described_class.string(key, default: 'any', staging: 'review')).to eq 'review'
    end

    it 'uses the local default in development and test' do
      in_environment('development')
      expect(described_class.string(key, local: 'asdf')).to eq 'asdf'

      in_environment('production')
      expect(described_class.string(key, local: 'asdf')).to be_nil
    end

    it 'prefers the named environment over local, and local over the plain default' do
      in_environment('test')

      expect(described_class.string(key, default: 'any', local: 'local', test: 'test')).to eq 'test'
      expect(described_class.string(key, default: 'any', local: 'local')).to eq 'local'
    end

    it 'lets an environment opt out of the default with nil' do
      in_environment('production')

      expect(described_class.string(key, default: 'dev-key', production: nil)).to be_nil
    end

    it 'still prefers a set value over any default' do
      in_environment('development')
      ENV[key] = 'set'

      expect(described_class.string(key, local: 'asdf')).to eq 'set'
    end

    it 'rejects an environment it does not know, to catch typos' do
      expect { described_class.string(key, prodution: nil) }.to raise_error(ArgumentError, /prodution/)
    end
  end

  describe '.array' do
    it 'splits a comma-separated value and trims each item' do
      ENV[key] = 'a@example.com, b@example.com,,c@example.com '

      expect(described_class.array(key)).to eq %w[a@example.com b@example.com c@example.com]
    end

    it 'falls back to the default when the key is missing' do
      ENV[key] = nil

      expect(described_class.array(key, default: %w[fallback])).to eq %w[fallback]
      expect(described_class.array(key)).to eq []
    end
  end

  describe '.boolean' do
    it 'reads the usual words for true and false, in any case' do
      { 'true' => true, 'TRUE' => true, 't' => true, '1' => true, 'yes' => true, 'Y' => true, 'on' => true,
        'enabled' => true,
        'false' => false, 'f' => false, '0' => false, 'no' => false, 'n' => false, 'Off' => false,
        'disabled' => false, }.each do |value, expected|
        ENV[key] = value

        expect(described_class.boolean(key)).to be(expected), "expected #{value.inspect} to be #{expected}"
      end
    end

    it 'rejects any other value rather than guessing, naming the key' do
      ENV[key] = 'nope'

      expect { described_class.boolean(key) }.to raise_error(ArgumentError, /ENV_VALUE_SPEC/)
    end

    it 'falls back to the default when the key is missing' do
      ENV[key] = nil

      expect(described_class.boolean(key, default: true)).to be true
      expect(described_class.boolean(key)).to be false
    end
  end
end
