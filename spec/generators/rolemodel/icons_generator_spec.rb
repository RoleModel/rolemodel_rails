require 'spec_helper'
require 'generators/rolemodel/optics/icons/icons_generator'

RSpec.describe Rolemodel::Optics::IconsGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

  it 'adds the correct helper and builders' do
    assert_file 'app/helpers/icon_helper.rb'

    assert_file 'app/icon_builders/icon_builder.rb'
    assert_file 'app/icon_builders/material_icon_builder.rb'
    assert_file 'app/icon_builders/phosphor_icon_builder.rb'
    assert_file 'app/icon_builders/tabler_icon_builder.rb'
    assert_file 'app/icon_builders/feather_icon_builder.rb'
    assert_file 'app/icon_builders/lucide_icon_builder.rb'
    assert_file 'app/icon_builders/custom_icon_builder.rb'
  end
end
