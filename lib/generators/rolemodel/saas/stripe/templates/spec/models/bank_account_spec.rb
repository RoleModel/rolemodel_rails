require 'rails_helper'

RSpec.describe Course, type: :model do

  describe 'validations' do
    let(:bank_account) { build :bank_account }

    it 'is valid' do
      expect(bank_account).to be_valid
    end

    it 'will not accept a false routing number' do
      bank_account.routing_number = '111111111'
      expect(bank_account).to_not be_valid
      expect(bank_account.errors[:routing_number]).to include('needs to be a valid routing number')
    end

    it 'will not accept a routing number with an incorrect length' do
      bank_account.routing_number = '1'
      expect(bank_account).to_not be_valid
      expect(bank_account.errors[:routing_number]).to include('must include 9 digits')
    end
  end

  describe 'encrpyted' do
    let(:routing_number) { '253177049' }
    let(:account_number) { '987654321' }
    let(:bank_account) { create :bank_account, routing_number: routing_number, account_number: account_number }

    describe '#routing_number' do
      it 'the value stored in the database is not the routing number entered' do
        expect(bank_account.encrypted_routing_number).not_to eq(routing_number)
      end

      it 'returns the decrypted bank account number' do
        expect(bank_account.routing_number).to eq(routing_number)
      end
    end

    describe '#account_number' do
      it 'the value stored in the database is not the account number entered' do
        expect(bank_account.encrypted_account_number).not_to eq(account_number)
      end

      it 'returns the decrypted bank account number' do
        expect(bank_account.account_number).to eq(account_number)
      end
    end
  end
end
