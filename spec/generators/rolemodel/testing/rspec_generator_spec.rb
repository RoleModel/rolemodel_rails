RSpec.describe Rolemodel::Testing::RspecGenerator, type: :generator do
  describe 'by default' do
    before { run_generator_against_test_app }

    it 'adds the correct helpers' do
      assert_file 'spec/support/helpers/action_cable_helper.rb'
      assert_file 'spec/support/helpers/capybara_helper.rb'
      assert_file 'spec/support/helpers/playwright_helper.rb'
      assert_file 'spec/support/helpers/select_helper.rb'
      assert_file 'spec/support/helpers/test_element_helper.rb'
    end

    it 'adds correct dependencies' do
      assert_file 'Gemfile' do |content|
        expect(content).to match(/rspec-rails/)
        expect(content).not_to match(/marsh_grass/)
        expect(content).not_to match(/pry/)
      end
    end
  end

  describe 'with marsh_grass option' do
    before { run_generator_against_test_app %w[--marsh-grass] }

    it 'adds the additional gems' do
      assert_file 'Gemfile' do |content|
        expect(content).to match(/rspec-rails/)
        expect(content).to match(/marsh_grass/)
        expect(content).to match(/pry/)
      end
    end
  end
end
