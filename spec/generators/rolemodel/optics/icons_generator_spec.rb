RSpec.describe Rolemodel::Optics::IconsGenerator, type: :generator do
  before do
    respond_to_prompt with: 'phosphor' # choose an icon library
    run_generator_against_test_app
  end

  it 'adds the correct helper and builders' do
    assert_file 'app/helpers/icon_helper.rb'
    assert_file 'app/icon_builders/icon_builder.rb'
    assert_file 'app/icon_builders/phosphor_icon_builder.rb'
  end
end
