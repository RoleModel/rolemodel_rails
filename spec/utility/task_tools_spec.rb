# frozen_string_literal: true

require 'rolemodel/utility/task_tools'

RSpec.describe Rolemodel::Utility::TaskTools do
  subject(:tools) { Object.new.extend(described_class) }

  describe '#sanitize_arguments' do
    let(:defaults) { { name: 'RoleModel', email: 'admin@example.com' } }

    it 'strips the values it keeps' do
      expect(tools.sanitize_arguments({ name: ' Jane ' }, defaults)).to eq(name: 'Jane', email: 'admin@example.com')
    end

    it 'falls back to the default for an argument skipped with _ or left blank' do
      expect(tools.sanitize_arguments({ name: '_', email: ' ' }, defaults)).to eq defaults
    end

    it 'keeps values that contain an underscore' do
      expect(tools.sanitize_arguments({ email: 'jane_doe@example.com' }, defaults)[:email]).to eq 'jane_doe@example.com'
    end
  end
end
