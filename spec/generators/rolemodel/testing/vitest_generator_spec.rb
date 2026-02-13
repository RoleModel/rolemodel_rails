RSpec.describe Rolemodel::Testing::VitestGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'adds the correct helpers' do
    assert_file 'vitest.config.js'
    assert_file 'spec/javascript/test-setup.js'
    assert_file 'spec/javascript/example.spec.js'

    assert_file 'package.json' do |content|
      expect(content).to include('"vitest"')
      expect(content).to include('"playwright"')
      expect(content).to include('@vitest/browser-playwright')
      expect(content).to include('@vitest/ui')

      expect(content).to include('"test": "NODE_ENV=test vitest"')
    end
  end
end
