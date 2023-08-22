require 'rails_helper'

RSpec.describe TurboFrameLinkHelper, type: :helper do
  describe '#modal_link_to' do
    it 'accepts an url and block' do
      expect(
        modal_link_to('http://www.example.com') do
          'Click here'
        end
      ).to eq '<a data-turbo-frame="modal" href="http://www.example.com">Click here</a>'
    end

    it 'accepts a name and an url' do
      expect(
        modal_link_to('Click here', 'http://www.example.com')
      ).to eq '<a data-turbo-frame="modal" href="http://www.example.com">Click here</a>'
    end

    it 'accepts a name, an url, and options' do
      expect(
        modal_link_to('Click here', 'http://www.example.com', class: 'btn')
      ).to eq '<a class="btn" data-turbo-frame="modal" href="http://www.example.com">Click here</a>'
    end
  end
end
