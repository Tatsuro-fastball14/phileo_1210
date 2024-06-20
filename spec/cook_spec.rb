require 'rails_helper'

RSpec.describe Cook, type: :model do
  let(:cook) { build(:cook) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(cook).to be_valid
    end

    it 'is not valid without a store_catchcopy' do
      cook.store_catchcopy = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without a sentence' do
      cook.sentence = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without an address' do
      cook.address = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without a phone_number' do
      cook.phone_number = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without a store' do
      cook.store = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without a category' do
      cook.category = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without a lat' do
      cook.lat = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without a lng' do
      cook.lng = nil
      expect(cook).not_to be_valid
    end

    it 'is not valid without an order' do
      cook.order = nil
      expect(cook).not_to be_valid
    end
  end
end
