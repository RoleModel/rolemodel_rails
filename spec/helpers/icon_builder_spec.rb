require 'action_view'
require 'erb'
require 'rolemodel/optics'


RSpec.describe Rolemodel::Optics::MaterialIconBuilder, type: :helper do
  include ActionView::Helpers

  let(:builder) { Rolemodel::Optics::MaterialIconBuilder.new('home', **options) }

  describe 'default options' do
    let(:options) { {} }
    it 'renders an icon with the correct class' do
      expect(builder.build).to eq('<span class="material-symbols-outlined icon" title="home">home</span>')
    end
  end

  describe 'hover_text'
  describe 'color'
  describe 'additional_classes'
end
