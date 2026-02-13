RSpec.describe Rolemodel::Optics::IconsGenerator, type: :generator do
  context 'default icon library' do
    before do
      respond_to_prompt with: 'material' # choose an icon library
      run_generator_against_test_app
    end

    it 'adds the correct helper and builders' do
      assert_file 'app/helpers/icon_helper.rb'
      assert_file 'app/icon_builders/icon_builder.rb'
      assert_file 'app/icon_builders/material_icon_builder.rb'
    end
  end

  context 'selecting an alternate icon library via command line option' do
    before { run_generator_against_test_app(['--phosphor']) }

    it 'adds the correct helper and builders' do
      assert_file 'app/helpers/icon_helper.rb'
      assert_file 'app/icon_builders/icon_builder.rb'
      assert_file 'app/icon_builders/phosphor_icon_builder.rb'
    end
  end

  context 're-running the generator' do
    it 'removes existing helper and builders before adding new ones' do
      assert_no_file 'app/helpers/icon_helper.rb'

      run_generator_against_test_app(['--tabler'])
      assert_file 'app/helpers/icon_helper.rb'
      assert_file 'app/icon_builders/tabler_icon_builder.rb'

      respond_to_prompt with: 'feather' # choose an icon library
      run_generator_against_test_app
      assert_file 'app/helpers/icon_helper.rb'
      assert_file 'app/icon_builders/feather_icon_builder.rb'

      assert_no_file 'app/icon_builders/tabler_icon_builder.rb'
      assert_no_file 'app/icon_builders/material_icon_builder.rb'
    end
  end
end
