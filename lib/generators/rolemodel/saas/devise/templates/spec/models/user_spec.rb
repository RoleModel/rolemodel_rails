# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates the default factory' do
      expect(build(:user)).to be_valid
    end

    it 'validates presence of first_name' do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'validates presence of last_name' do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'validates presence of role' do
      user = build(:user, role: nil)
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("can't be blank")
    end
  end
end
