# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resources::Handler do
  it 'returns error messages when invalid' do
    allow(described_class).to receive(:schema).and_return('docs://')
    allow_any_instance_of(described_class).to receive(:valid?).and_return(false)
    allow_any_instance_of(described_class).to receive_message_chain(:errors,
                                                                    :full_messages).and_return(['Invalid params'])
    expect do
      described_class.call({ uri: 'docs://missing-doc' }, { current_user: nil })
    end.to raise_error(
      MCP::Server::RequestHandlerError,
      /Invalid params/
    )
  end
end
