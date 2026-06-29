RSpec.describe Rolemodel::Optics::IconsGenerator, type: :generator do
  context 'default icon library' do
    before do
      respond_to_prompt with: 'material' # choose an icon library
      run_generator_against_test_app
    end

    it 'adds the correct helper' do
      assert_file 'app/helpers/icon_helper.rb' do |helper|
        assert_instance_method :icon, helper
        assert_match(/MaterialIconBuilder/, helper)
      end
    end
  end

  context 'selecting an alternate icon library via command line option' do
    before { run_generator_against_test_app(['--phosphor']) }

    it 'adds the correct helper' do
      assert_file 'app/helpers/icon_helper.rb' do |helper|
        assert_instance_method :icon, helper
        assert_match(/PhosphorIconBuilder/, helper)
      end
    end
  end

  context 'selecting an alternate icon library via prompt' do
    before do
      respond_to_prompt with: 'feather' # choose an icon library
      run_generator_against_test_app
    end

    it 'adds the correct helper' do
      assert_file 'app/helpers/icon_helper.rb' do |helper|
        assert_instance_method :icon, helper
        assert_match(/FeatherIconBuilder/, helper)
      end
    end
  end

  context 're-running the generator' do
    it 'removes existing helper and builders before adding new ones' do
      assert_no_file 'app/helpers/icon_helper.rb'

      run_generator_against_test_app(['--tabler'])
      assert_file 'app/helpers/icon_helper.rb' do |helper|
        assert_instance_method :icon, helper
        assert_match(/TablerIconBuilder/, helper)
        assert_no_match(/PhosphorIconBuilder/, helper)
      end

      run_generator_against_test_app(['--lucide'])
      assert_file 'app/helpers/icon_helper.rb' do |helper|
        assert_instance_method :icon, helper
        assert_match(/LucideIconBuilder/, helper)
        assert_no_match(/TablerIconBuilder/, helper)
      end
    end
  end

  context 'installing builders' do
    before do
      run_generator_against_test_app(['--phosphor', '--install-builders'])
    end

    it 'copies the base IconBuilder and the chosen library builder to the app lib directory' do
      assert_file 'lib/rolemodel/optics/icon_builder.rb'
      assert_file 'lib/rolemodel/optics/phosphor_icon_builder.rb'
    end
  end

  context 'not installing builders (default)' do
    before { run_generator_against_test_app(['--phosphor']) }

    it 'does not copy any builder files to the app lib directory' do
      assert_no_file 'lib/rolemodel/optics/icon_builder.rb'
      assert_no_file 'lib/rolemodel/optics/phosphor_icon_builder.rb'
    end
  end
end
