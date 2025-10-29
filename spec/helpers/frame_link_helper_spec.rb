require 'spec_helper'
require 'action_view/helpers'
require 'generators/rolemodel/ui_components/modals/templates/app/helpers/turbo_frame_link_helper.rb'

RSpec.describe TurboFrameLinkHelper, type: :helper do
  include ActionView::Helpers
  include TurboFrameLinkHelper

  it 'generates the correct link HTML' do
    no_block_modal_link_with_options = modal_link_to('My Link', '/path', class: ['true--class' => true, 'false--class' => false], data: { foo: 'bar' }, disabled: false)
    no_block_panel_link_no_options = panel_link_to('My Link', '/path')
    block_top_link_with_options = link_to_top('/path', class: ['always--class', 'true--class' => true, 'false--class' => false], disabled: true) { 'My Link' }
    block_modal_link_no_options = modal_link_to('/path') { 'My Link' }

    expect(no_block_modal_link_with_options).to eq('<a class="true--class" data-turbo-frame="modal" data-foo="bar" href="/path">My Link</a>')
    expect(no_block_panel_link_no_options).to eq('<a data-turbo-frame="panel" href="/path">My Link</a>')
    expect(block_top_link_with_options).to eq('<a class="always--class true--class" disabled="disabled" data-turbo-frame="_top" href="/path">My Link</a>')
    expect(block_modal_link_no_options).to eq('<a data-turbo-frame="modal" href="/path">My Link</a>')
  end
end
