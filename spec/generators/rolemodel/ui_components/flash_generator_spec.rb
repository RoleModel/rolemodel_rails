RSpec.describe Rolemodel::UiComponents::FlashGenerator, type: :generator do
  before do
    run_generators generators: [::Rolemodel::SlimGenerator, described_class]
  end

  it 'adds the flash file' do
    assert_file 'app/views/application/_flash.html.slim'
    assert_file 'spec/support/matchers/flash_matchers.rb'

    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to include("= render 'flash'")
    end
  end
end
